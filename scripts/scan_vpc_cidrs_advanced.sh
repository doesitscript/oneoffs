#!/bin/bash

# Advanced VPC CIDR Scanner for AWS Accounts
# Scans ue2 and uw2 regions for VPC CIDR allocations
# Compares against expected /14 and /16 ranges with detailed analysis

set -euo pipefail

# Check if AWS CLI is available
if ! command -v aws >/dev/null 2>&1; then
    echo "ERROR: AWS CLI is not installed or not in PATH" >&2
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "ERROR: AWS credentials not configured. Please run 'aws configure' or set AWS environment variables." >&2
    echo "You can also use AWS SSO, IAM roles, or other credential methods." >&2
    exit 1
fi

# Define the regions to scan
REGIONS=("us-east-2" "us-west-2")

# Expected CIDR ranges
EXPECTED_14_RANGES=("10.60.0.0/14" "10.160.0.0/14")
EXPECTED_16_RANGES=("10.60.0.0/16" "10.160.0.0/16")
ONPREM_RANGES=("10.91.0.0/16" "10.131.0.0/16")

# Function to convert CIDR to network and broadcast addresses
cidr_to_range() {
    local cidr="$1"
    local ip=$(echo "$cidr" | cut -d'/' -f1)
    local prefix=$(echo "$cidr" | cut -d'/' -f2)
    
    # Convert IP to decimal
    local a=$(echo "$ip" | cut -d'.' -f1)
    local b=$(echo "$ip" | cut -d'.' -f2)
    local c=$(echo "$ip" | cut -d'.' -f3)
    local d=$(echo "$ip" | cut -d'.' -f4)
    
    local ip_decimal=$((a * 256 * 256 * 256 + b * 256 * 256 + c * 256 + d))
    local mask=$((0xFFFFFFFF << (32 - prefix)))
    local network=$((ip_decimal & mask))
    local broadcast=$((network | (~mask & 0xFFFFFFFF)))
    
    echo "$network $broadcast"
}

# Function to check if CIDR is within a range
cidr_in_range() {
    local cidr="$1"
    local range="$2"
    
    # Get ranges for both CIDRs
    local cidr_range=$(cidr_to_range "$cidr")
    local range_range=$(cidr_to_range "$range")
    
    local cidr_start=$(echo "$cidr_range" | cut -d' ' -f1)
    local cidr_end=$(echo "$cidr_range" | cut -d' ' -f2)
    local range_start=$(echo "$range_range" | cut -d' ' -f1)
    local range_end=$(echo "$range_range" | cut -d' ' -f2)
    
    # Check if CIDR is completely within the range
    if [ "$cidr_start" -ge "$range_start" ] && [ "$cidr_end" -le "$range_end" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check for overlaps with on-prem ranges
check_onprem_overlap() {
    local cidr="$1"
    for onprem_range in "${ONPREM_RANGES[@]}"; do
        if cidr_in_range "$cidr" "$onprem_range"; then
            echo "OVERLAP_ONPREM"
            return
        fi
    done
    echo "OK"
}

# Function to analyze CIDR
analyze_cidr() {
    local cidr="$1"
    local inside_14="NO"
    local matches_16="NO"
    local notes=""
    
    # Check if inside /14 ranges
    for range_14 in "${EXPECTED_14_RANGES[@]}"; do
        if cidr_in_range "$cidr" "$range_14"; then
            inside_14="YES"
            break
        fi
    done
    
    # Check if matches /16 ranges
    for range_16 in "${EXPECTED_16_RANGES[@]}"; do
        if cidr_in_range "$cidr" "$range_16"; then
            matches_16="YES"
            break
        fi
    done
    
    # Check for on-prem overlaps
    local overlap_status=$(check_onprem_overlap "$cidr")
    if [ "$overlap_status" = "OVERLAP_ONPREM" ]; then
        notes="OVERLAP_ONPREM"
    elif [ "$inside_14" = "NO" ]; then
        notes="OUTSIDE_EXPECTED_RANGES"
    fi
    
    echo "$inside_14|$matches_16|$notes"
}

# Function to get subnet information for a VPC
get_subnet_info() {
    local vpc_id="$1"
    local region="$2"
    
    aws ec2 describe-subnets \
        --region "$region" \
        --filters "Name=vpc-id,Values=$vpc_id" \
        --query 'Subnets[*].[SubnetId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' \
        --output text 2>/dev/null | while read -r subnet_id subnet_cidr subnet_name; do
        if [ "$subnet_name" = "None" ] || [ -z "$subnet_name" ]; then
            subnet_name="$subnet_id"
        fi
        echo "$subnet_id:$subnet_cidr:$subnet_name"
    done
}

# Print header
echo "Account|Region|VPC Name/ID|CIDR(s)|Inside /14?|Matches Jared's /16?|Notes|Subnets"
echo "-------|------|-----------|-------|-----------|-------------------|-----|--------"

# Get current account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "UNKNOWN")

# Scan each region
for region in "${REGIONS[@]}"; do
    echo "Scanning region: $region" >&2
    
    # Get all VPCs in the region
    aws ec2 describe-vpcs \
        --region "$region" \
        --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0],CidrBlock,CidrBlockAssociationSet[*].CidrBlock]' \
        --output text 2>/dev/null | while read -r vpc_id vpc_name primary_cidr secondary_cidrs; do
        
        # Clean up the VPC name (remove None if no name tag)
        if [ "$vpc_name" = "None" ] || [ -z "$vpc_name" ]; then
            vpc_name="$vpc_id"
        fi
        
        # Combine all CIDRs
        all_cidrs="$primary_cidr"
        if [ -n "$secondary_cidrs" ] && [ "$secondary_cidrs" != "None" ]; then
            all_cidrs="$primary_cidr, $secondary_cidrs"
        fi
        
        # Analyze the primary CIDR
        analysis=$(analyze_cidr "$primary_cidr")
        inside_14=$(echo "$analysis" | cut -d'|' -f1)
        matches_16=$(echo "$analysis" | cut -d'|' -f2)
        notes=$(echo "$analysis" | cut -d'|' -f3)
        
        # Get subnet information
        subnet_info=$(get_subnet_info "$vpc_id" "$region" | tr '\n' ';' | sed 's/;$//')
        if [ -z "$subnet_info" ]; then
            subnet_info="No subnets found"
        fi
        
        # Output the result
        echo "$ACCOUNT_ID|$region|$vpc_name|$all_cidrs|$inside_14|$matches_16|$notes|$subnet_info"
    done
done

echo "Scan completed for regions: ${REGIONS[*]}" >&2


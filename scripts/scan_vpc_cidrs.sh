#!/bin/bash

# VPC CIDR Scanner for AWS Accounts
# Scans ue2 and uw2 regions for VPC CIDR allocations
# Compares against expected /14 and /16 ranges

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

# Function to check if CIDR is within a range
cidr_in_range() {
    local cidr="$1"
    local range="$2"
    
    # Use ipcalc if available, otherwise use a simple check
    if command -v ipcalc >/dev/null 2>&1; then
        ipcalc -c "$cidr" "$range" >/dev/null 2>&1
    else
        # Simple check for /16 ranges
        local cidr_base=$(echo "$cidr" | cut -d'/' -f1 | cut -d'.' -f1-2)
        local range_base=$(echo "$range" | cut -d'/' -f1 | cut -d'.' -f1-2)
        [ "$cidr_base" = "$range_base" ]
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

# Print header
echo "Account|Region|VPC Name/ID|CIDR(s)|Inside /14?|Matches Jared's /16?|Notes"
echo "-------|------|-----------|-------|-----------|-------------------|-----"

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
        
        # Output the result
        echo "$ACCOUNT_ID|$region|$vpc_name|$all_cidrs|$inside_14|$matches_16|$notes"
    done
done

echo "Scan completed for regions: ${REGIONS[*]}" >&2
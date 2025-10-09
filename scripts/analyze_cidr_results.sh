#!/bin/bash

# Corrected CIDR Analysis Script
# Properly analyzes the scan results

set -euo pipefail

INPUT_FILE="/Users/a805120/develop/oneoffs/docs/aws_cidr_verification_detailed.csv"
OUTPUT_FILE="/Users/a805120/develop/oneoffs/docs/corrected_cidr_analysis.md"

# Expected CIDR ranges
EXPECTED_14_RANGES=("10.60.0.0/14" "10.160.0.0/14")
ONPREM_RANGES=("10.91.0.0/16" "10.131.0.0/16")

# Function to check if CIDR is within a range (corrected logic)
cidr_in_range() {
    local cidr="$1"
    local range="$2"
    
    # Extract network and prefix from CIDR
    local cidr_network=$(echo "$cidr" | cut -d'/' -f1)
    local cidr_prefix=$(echo "$cidr" | cut -d'/' -f2)
    local range_network=$(echo "$range" | cut -d'/' -f1)
    local range_prefix=$(echo "$range" | cut -d'/' -f2)
    
    # Convert to decimal for comparison
    local cidr_decimal=$(ip_to_decimal "$cidr_network")
    local range_decimal=$(ip_to_decimal "$range_network")
    
    # Calculate network masks
    local cidr_mask=$((0xFFFFFFFF << (32 - cidr_prefix)))
    local range_mask=$((0xFFFFFFFF << (32 - range_prefix)))
    
    # Calculate network addresses
    local cidr_net=$((cidr_decimal & cidr_mask))
    local range_net=$((range_decimal & range_mask))
    
    # Check if CIDR network is within range network
    if [ "$cidr_prefix" -ge "$range_prefix" ]; then
        # CIDR is more specific, check if it's within the range
        local cidr_in_range_net=$((cidr_decimal & range_mask))
        [ "$cidr_in_range_net" = "$range_net" ]
    else
        # CIDR is less specific, check if range is within CIDR
        local range_in_cidr_net=$((range_decimal & cidr_mask))
        [ "$range_in_cidr_net" = "$cidr_net" ]
    fi
}

# Function to convert IP to decimal
ip_to_decimal() {
    local ip="$1"
    local a=$(echo "$ip" | cut -d'.' -f1)
    local b=$(echo "$ip" | cut -d'.' -f2)
    local c=$(echo "$ip" | cut -d'.' -f3)
    local d=$(echo "$ip" | cut -d'.' -f4)
    echo $((a * 256 * 256 * 256 + b * 256 * 256 + c * 256 + d))
}

# Function to check for overlaps with on-prem ranges (corrected)
check_onprem_overlap() {
    local cidr="$1"
    local cidr_network=$(echo "$cidr" | cut -d'/' -f1)
    local cidr_prefix=$(echo "$cidr" | cut -d'/' -f2)
    
    # Extract first two octets
    local cidr_base=$(echo "$cidr_network" | cut -d'.' -f1-2)
    
    for onprem_range in "${ONPREM_RANGES[@]}"; do
        local onprem_network=$(echo "$onprem_range" | cut -d'/' -f1)
        local onprem_base=$(echo "$onprem_network" | cut -d'.' -f1-2)
        
        # Check if first two octets match (simple overlap check)
        if [ "$cidr_base" = "$onprem_base" ]; then
            echo "OVERLAP_ONPREM"
            return
        fi
    done
    echo "OK"
}

# Function to check if CIDR is within expected /14 ranges (corrected)
check_expected_range() {
    local cidr="$1"
    local cidr_network=$(echo "$cidr" | cut -d'/' -f1)
    local cidr_prefix=$(echo "$cidr" | cut -d'/' -f2)
    
    # Extract first two octets
    local cidr_base=$(echo "$cidr_network" | cut -d'.' -f1-2)
    
    for range_14 in "${EXPECTED_14_RANGES[@]}"; do
        local range_network=$(echo "$range_14" | cut -d'/' -f1)
        local range_base=$(echo "$range_network" | cut -d'.' -f1-2)
        
        # Check if first two octets match (simple range check)
        if [ "$cidr_base" = "$range_base" ]; then
            echo "YES"
            return
        fi
    done
    echo "NO"
}

# Generate corrected analysis
generate_corrected_analysis() {
    echo "# Corrected AWS CIDR Usage Analysis" > "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "## Scan Overview" >> "$OUTPUT_FILE"
    echo "- **Analysis Date**: $(date)" >> "$OUTPUT_FILE"
    echo "- **Source Data**: $INPUT_FILE" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Count total VPCs
    local total_vpcs=$(tail -n +2 "$INPUT_FILE" | wc -l)
    echo "- **Total VPCs Scanned**: $total_vpcs" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Analyze CIDRs in expected ranges
    echo "## CIDRs in Expected /14 Ranges" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "| Account ID | Profile | Friendly Name | Region | VPC ID | VPC Name | CIDR(s) | Notes |" >> "$OUTPUT_FILE"
    echo "|------------|---------|---------------|--------|--------|----------|---------|-------|" >> "$OUTPUT_FILE"
    
    # Filter for CIDRs in expected ranges
    tail -n +2 "$INPUT_FILE" | while IFS='|' read -r account_id profile friendly_name region vpc_id vpc_name cidr source ipam_match expected_range onprem_overlap notes; do
        # Check if this CIDR is in expected range
        if [ "$(check_expected_range "$cidr")" = "YES" ]; then
            # Check for on-prem overlap
            local onprem_status=$(check_onprem_overlap "$cidr")
            local corrected_notes="OK"
            if [ "$onprem_status" = "OVERLAP_ONPREM" ]; then
                corrected_notes="OVERLAP_ONPREM"
            fi
            
            echo "| $account_id | $profile | $friendly_name | $region | $vpc_id | $vpc_name | $cidr | $corrected_notes |" >> "$OUTPUT_FILE"
        fi
    done
    
    echo "" >> "$OUTPUT_FILE"
    
    # Count statistics
    local in_expected=0
    local outside_expected=0
    local onprem_conflicts=0
    local ipam_allocated=0
    local deployed_only=0
    
    tail -n +2 "$INPUT_FILE" | while IFS='|' read -r account_id profile friendly_name region vpc_id vpc_name cidr source ipam_match expected_range onprem_overlap notes; do
        if [ "$(check_expected_range "$cidr")" = "YES" ]; then
            in_expected=$((in_expected + 1))
        else
            outside_expected=$((outside_expected + 1))
        fi
        
        if [ "$(check_onprem_overlap "$cidr")" = "OVERLAP_ONPREM" ]; then
            onprem_conflicts=$((onprem_conflicts + 1))
        fi
        
        if [ "$ipam_match" = "YES" ]; then
            ipam_allocated=$((ipam_allocated + 1))
        else
            deployed_only=$((deployed_only + 1))
        fi
    done
    
    echo "## Summary Statistics" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "- **CIDRs within expected /14 ranges**: $in_expected" >> "$OUTPUT_FILE"
    echo "- **CIDRs outside expected ranges**: $outside_expected" >> "$OUTPUT_FILE"
    echo "- **CIDRs with on-premises conflicts**: $onprem_conflicts" >> "$OUTPUT_FILE"
    echo "- **CIDRs with IPAM allocations**: $ipam_allocated" >> "$OUTPUT_FILE"
    echo "- **CIDRs deployed without IPAM**: $deployed_only" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Generate recommendations
    echo "## Recommendations" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    if [ "$deployed_only" -gt 0 ]; then
        echo "- **Action Required**: $deployed_only CIDRs are deployed without IPAM allocations" >> "$OUTPUT_FILE"
        echo "  - Consider creating IPAM allocations for these CIDRs to maintain proper tracking" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
    
    if [ "$outside_expected" -gt 0 ]; then
        echo "- **Action Required**: $outside_expected CIDRs fall outside expected /14 ranges" >> "$OUTPUT_FILE"
        echo "  - Review these CIDRs and consider migrating to expected ranges" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
    
    if [ "$onprem_conflicts" -gt 0 ]; then
        echo "- **Critical**: $onprem_conflicts CIDRs overlap with on-premises ranges" >> "$OUTPUT_FILE"
        echo "  - These must be resolved immediately to prevent network conflicts" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
    
    if [ "$deployed_only" -eq 0 ] && [ "$outside_expected" -eq 0 ] && [ "$onprem_conflicts" -eq 0 ]; then
        echo "- **All Good**: No issues detected. All CIDRs are properly allocated and within expected ranges." >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
    
    echo "## Firewall Rule Recommendations" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Based on the analysis, the following specific CIDR blocks should be used for firewall rules instead of broad ranges:" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Extract unique CIDRs in expected ranges for firewall rules
    echo "### us-east-2 (10.60.0.0/14 range):" >> "$OUTPUT_FILE"
    tail -n +2 "$INPUT_FILE" | while IFS='|' read -r account_id profile friendly_name region vpc_id vpc_name cidr source ipam_match expected_range onprem_overlap notes; do
        if [ "$region" = "us-east-2" ] && [ "$(check_expected_range "$cidr")" = "YES" ]; then
            echo "- $cidr - $friendly_name ($vpc_name)" >> "$OUTPUT_FILE"
        fi
    done | sort -u >> "$OUTPUT_FILE"
    
    echo "" >> "$OUTPUT_FILE"
    echo "### us-west-2 (10.160.0.0/14 range):" >> "$OUTPUT_FILE"
    tail -n +2 "$INPUT_FILE" | while IFS='|' read -r account_id profile friendly_name region vpc_id vpc_name cidr source ipam_match expected_range onprem_overlap notes; do
        if [ "$region" = "us-west-2" ] && [ "$(check_expected_range "$cidr")" = "YES" ]; then
            echo "- $cidr - $friendly_name ($vpc_name)" >> "$OUTPUT_FILE"
        fi
    done | sort -u >> "$OUTPUT_FILE"
}

# Run the analysis
generate_corrected_analysis

echo "Corrected analysis generated: $OUTPUT_FILE"




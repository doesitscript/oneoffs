#!/bin/bash

# Comprehensive AWS CIDR Usage Verification Script
# Compares IPAM allocations against actual VPC usage across all accounts

set -euo pipefail

# Configuration
NETWORK_HUB_PROFILE="Network_Hub_207567762220_admin"
OUTPUT_DIR="/Users/a805120/develop/oneoffs/docs"
TEMP_DIR="/tmp/aws_cidr_scan_$$"

# Expected CIDR ranges
EXPECTED_14_RANGES=("10.60.0.0/14" "10.160.0.0/14")
ONPREM_RANGES=("10.91.0.0/16" "10.131.0.0/16")

# Create temp directory
mkdir -p "$TEMP_DIR"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

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

# Function to check if CIDR is within expected /14 ranges
check_expected_range() {
    local cidr="$1"
    for range_14 in "${EXPECTED_14_RANGES[@]}"; do
        if cidr_in_range "$cidr" "$range_14"; then
            echo "YES"
            return
        fi
    done
    echo "NO"
}

# Function to get account friendly name from profile
get_account_friendly_name() {
    local profile="$1"
    # Extract account number from profile name
    local account_num=$(echo "$profile" | grep -o '[0-9]\{12\}' | tail -1)
    
    # Map to friendly names based on common patterns
    case "$profile" in
        *CASTSoftware*|*castsoftware*)
            echo "CAST Software Dev"
            ;;
        *Network_Hub*)
            echo "Network Hub"
            ;;
        *InfrastructureSharedServices*)
            echo "Infrastructure Shared Services"
            ;;
        *SDLC_DEV*)
            echo "SDLC Development"
            ;;
        *SDLC_QA*)
            echo "SDLC QA"
            ;;
        *SDLC_UAT*)
            echo "SDLC UAT"
            ;;
        *Security_Tooling*)
            echo "Security Tooling"
            ;;
        *Log_Archive*)
            echo "Log Archive"
            ;;
        *Audit*)
            echo "Audit"
            ;;
        *)
            echo "Account $account_num"
            ;;
    esac
}

# Step 1: Scan Network Hub for IPAM pools and allocations
scan_ipam_allocations() {
    log "Step 1: Scanning Network Hub for IPAM pools and allocations"
    
    local ipam_file="$TEMP_DIR/ipam_allocations.txt"
    
    # Get all IPAM pools
    aws ipam describe-ipam-pools \
        --profile "$NETWORK_HUB_PROFILE" \
        --query 'IpamPools[*].[IpamPoolId,Description,AddressFamily,State]' \
        --output text > "$TEMP_DIR/ipam_pools.txt" 2>/dev/null || {
        log "Warning: Could not access IPAM pools. IPAM may not be configured or accessible."
        touch "$ipam_file"
        return
    }
    
    # Get allocations for each pool
    while read -r pool_id description family state; do
        if [ "$state" = "create-complete" ]; then
            log "Scanning IPAM pool: $pool_id ($description)"
            
            # Get allocations for this pool
            aws ipam get-ipam-pool-allocations \
                --profile "$NETWORK_HUB_PROFILE" \
                --ipam-pool-id "$pool_id" \
                --query 'IpamPoolAllocations[*].[Cidr,ResourceId,ResourceOwner,ResourceRegion,ResourceType]' \
                --output text 2>/dev/null | while read -r cidr resource_id owner region resource_type; do
                if [ -n "$cidr" ] && [ "$cidr" != "None" ]; then
                    echo "$cidr|$resource_id|$owner|$region|$resource_type|$description" >> "$ipam_file"
                fi
            done
        fi
    done < "$TEMP_DIR/ipam_pools.txt"
    
    log "IPAM scan completed. Found $(wc -l < "$ipam_file") allocations."
}

# Step 2: Scan all AWS accounts for VPCs
scan_all_accounts() {
    log "Step 2: Scanning all AWS accounts for VPCs"
    
    local vpc_file="$TEMP_DIR/all_vpcs.txt"
    local profiles_file="$TEMP_DIR/aws_profiles.txt"
    
    # Get all profiles
    aws configure list-profiles > "$profiles_file"
    
    # Get all enabled regions
    local regions=($(aws ec2 describe-regions \
        --profile "$NETWORK_HUB_PROFILE" \
        --query 'Regions[?OptInStatus==`opt-in-not-required` || OptInStatus==`opted-in`].RegionName' \
        --output text))
    
    log "Found ${#regions[@]} enabled regions: ${regions[*]}"
    
    # Scan each profile
    while read -r profile; do
        log "Scanning profile: $profile"
        
        # Get account ID
        local account_id
        account_id=$(aws sts get-caller-identity \
            --profile "$profile" \
            --query Account \
            --output text 2>/dev/null) || {
            log "Warning: Could not get account ID for profile $profile"
            continue
        }
        
        local friendly_name=$(get_account_friendly_name "$profile")
        
        # Scan each region
        for region in "${regions[@]}"; do
            log "  Scanning region: $region"
            
            # Get all VPCs in this region
            aws ec2 describe-vpcs \
                --profile "$profile" \
                --region "$region" \
                --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0],CidrBlock,CidrBlockAssociationSet[*].CidrBlock]' \
                --output text 2>/dev/null | while read -r vpc_id vpc_name primary_cidr secondary_cidrs; do
                
                # Clean up the VPC name
                if [ "$vpc_name" = "None" ] || [ -z "$vpc_name" ]; then
                    vpc_name="$vpc_id"
                fi
                
                # Combine all CIDRs
                local all_cidrs="$primary_cidr"
                if [ -n "$secondary_cidrs" ] && [ "$secondary_cidrs" != "None" ]; then
                    all_cidrs="$primary_cidr, $secondary_cidrs"
                fi
                
                # Output VPC information
                echo "$account_id|$profile|$friendly_name|$region|$vpc_id|$vpc_name|$all_cidrs" >> "$vpc_file"
            done
        done
    done < "$profiles_file"
    
    log "VPC scan completed. Found $(wc -l < "$vpc_file") VPCs across all accounts."
}

# Step 3: Compare VPC CIDRs against IPAM allocations
compare_cidrs() {
    log "Step 3: Comparing VPC CIDRs against IPAM allocations"
    
    local comparison_file="$TEMP_DIR/cidr_comparison.txt"
    local ipam_file="$TEMP_DIR/ipam_allocations.txt"
    local vpc_file="$TEMP_DIR/all_vpcs.txt"
    
    # Create header
    echo "Account ID|Profile|Friendly Name|Region|VPC ID|VPC Name|CIDR(s)|Source|IPAM Match|Expected Range|On-Prem Overlap|Notes" > "$comparison_file"
    
    # Process each VPC
    while IFS='|' read -r account_id profile friendly_name region vpc_id vpc_name all_cidrs; do
        # Split CIDRs and process each one
        echo "$all_cidrs" | tr ',' '\n' | while read -r cidr; do
            cidr=$(echo "$cidr" | xargs) # trim whitespace
            
            # Check if this CIDR matches any IPAM allocation
            local ipam_match="NO"
            local ipam_source=""
            
            if [ -f "$ipam_file" ] && [ -s "$ipam_file" ]; then
                while IFS='|' read -r ipam_cidr resource_id owner ipam_region resource_type description; do
                    if [ "$cidr" = "$ipam_cidr" ]; then
                        ipam_match="YES"
                        ipam_source="IPAM: $description"
                        break
                    fi
                done < "$ipam_file"
            fi
            
            # If no IPAM match, mark as deployed
            if [ "$ipam_match" = "NO" ]; then
                ipam_source="Deployed"
            fi
            
            # Check expected ranges
            local expected_range=$(check_expected_range "$cidr")
            
            # Check on-prem overlaps
            local onprem_overlap=$(check_onprem_overlap "$cidr")
            
            # Generate notes
            local notes=""
            if [ "$expected_range" = "NO" ]; then
                notes="OUTSIDE_EXPECTED_RANGES"
            fi
            if [ "$onprem_overlap" = "OVERLAP_ONPREM" ]; then
                if [ -n "$notes" ]; then
                    notes="$notes, OVERLAP_ONPREM"
                else
                    notes="OVERLAP_ONPREM"
                fi
            fi
            if [ "$ipam_match" = "NO" ] && [ "$ipam_source" = "Deployed" ]; then
                if [ -n "$notes" ]; then
                    notes="$notes, NO_IPAM_ALLOCATION"
                else
                    notes="NO_IPAM_ALLOCATION"
                fi
            fi
            if [ -z "$notes" ]; then
                notes="OK"
            fi
            
            # Output comparison result
            echo "$account_id|$profile|$friendly_name|$region|$vpc_id|$vpc_name|$cidr|$ipam_source|$ipam_match|$expected_range|$onprem_overlap|$notes" >> "$comparison_file"
        done
    done < "$vpc_file"
    
    log "Comparison completed. Results saved to $comparison_file"
}

# Step 4: Generate summary and output
generate_summary() {
    log "Step 4: Generating summary and final output"
    
    local comparison_file="$TEMP_DIR/cidr_comparison.txt"
    local summary_file="$OUTPUT_DIR/aws_cidr_verification_summary.md"
    local detailed_file="$OUTPUT_DIR/aws_cidr_verification_detailed.csv"
    
    # Copy detailed results
    cp "$comparison_file" "$detailed_file"
    
    # Generate summary
    cat > "$summary_file" << EOF
# AWS CIDR Usage Verification Summary

## Scan Overview
- **Scan Date**: $(date)
- **Network Hub Profile**: $NETWORK_HUB_PROFILE
- **Total VPCs Scanned**: $(tail -n +2 "$comparison_file" | wc -l)
- **IPAM Allocations Found**: $(wc -l < "$TEMP_DIR/ipam_allocations.txt")

## Key Findings

### IPAM vs Deployed CIDRs
EOF

    # Count IPAM matches
    local ipam_matches=$(tail -n +2 "$comparison_file" | cut -d'|' -f9 | grep -c "YES" || echo "0")
    local deployed_only=$(tail -n +2 "$comparison_file" | cut -d'|' -f9 | grep -c "NO" || echo "0")
    
    cat >> "$summary_file" << EOF
- **CIDRs with IPAM allocations**: $ipam_matches
- **CIDRs deployed without IPAM**: $deployed_only

### Range Compliance
EOF

    # Count expected range compliance
    local in_expected=$(tail -n +2 "$comparison_file" | cut -d'|' -f10 | grep -c "YES" || echo "0")
    local outside_expected=$(tail -n +2 "$comparison_file" | cut -d'|' -f10 | grep -c "NO" || echo "0")
    
    cat >> "$summary_file" << EOF
- **CIDRs within expected /14 ranges**: $in_expected
- **CIDRs outside expected ranges**: $outside_expected

### On-Premises Conflicts
EOF

    # Count on-prem overlaps
    local onprem_conflicts=$(tail -n +2 "$comparison_file" | cut -d'|' -f11 | grep -c "OVERLAP_ONPREM" || echo "0")
    
    cat >> "$summary_file" << EOF
- **CIDRs overlapping with on-premises**: $onprem_conflicts

## Detailed Results
See \`aws_cidr_verification_detailed.csv\` for complete results.

## Recommendations
EOF

    if [ "$deployed_only" -gt 0 ]; then
        cat >> "$summary_file" << EOF
- **Action Required**: $deployed_only CIDRs are deployed without IPAM allocations
- Consider creating IPAM allocations for these CIDRs to maintain proper tracking
EOF
    fi

    if [ "$outside_expected" -gt 0 ]; then
        cat >> "$summary_file" << EOF
- **Action Required**: $outside_expected CIDRs fall outside expected /14 ranges
- Review these CIDRs and consider migrating to expected ranges
EOF
    fi

    if [ "$onprem_conflicts" -gt 0 ]; then
        cat >> "$summary_file" << EOF
- **Critical**: $onprem_conflicts CIDRs overlap with on-premises ranges
- These must be resolved immediately to prevent network conflicts
EOF
    fi

    if [ "$deployed_only" -eq 0 ] && [ "$outside_expected" -eq 0 ] && [ "$onprem_conflicts" -eq 0 ]; then
        cat >> "$summary_file" << EOF
- **All Good**: No issues detected. All CIDRs are properly allocated and within expected ranges.
EOF
    fi

    log "Summary generated: $summary_file"
    log "Detailed results: $detailed_file"
}

# Main execution
main() {
    log "Starting AWS CIDR Usage Verification"
    log "Output directory: $OUTPUT_DIR"
    
    # Step 1: Scan IPAM allocations
    scan_ipam_allocations
    
    # Step 2: Scan all accounts
    scan_all_accounts
    
    # Step 3: Compare CIDRs
    compare_cidrs
    
    # Step 4: Generate summary
    generate_summary
    
    log "Verification completed successfully!"
    log "Results saved to: $OUTPUT_DIR"
    
    # Cleanup
    rm -rf "$TEMP_DIR"
}

# Run main function
main "$@"




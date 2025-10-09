#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== EC2 Instance Search Across ALL Accounts ===${NC}"
echo -e "${YELLOW}Searching us-east-2 and us-west-2 regions${NC}"
echo ""

# Get all profiles dynamically
profiles=($(aws configure list-profiles))
regions=("us-east-2" "us-west-2")
total_instances=0
accounts_with_instances=0

echo -e "${BLUE}Found ${#profiles[@]} AWS profiles to check${NC}"
echo ""

for profile in "${profiles[@]}"; do
    echo -e "${GREEN}=== Checking Profile: $profile ===${NC}"
    profile_instances=0
    
    for region in "${regions[@]}"; do
        echo -e "${YELLOW}Region: $region${NC}"
        
        # Get instances for this profile and region
        instances=$(aws ec2 describe-instances \
            --profile "$profile" \
            --region "$region" \
            --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,LaunchTime,Tags[?Key==`Name`].Value|[0]]' \
            --output text 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$instances" ]; then
            echo "$instances" | while read -r instance_id state instance_type launch_time name; do
                if [ "$instance_id" != "None" ] && [ -n "$instance_id" ]; then
                    echo -e "  ${GREEN}✓${NC} $instance_id | $state | $instance_type | $name"
                fi
            done
            # Count instances for this region
            region_count=$(echo "$instances" | grep -v "^$" | wc -l)
            profile_instances=$((profile_instances + region_count))
        else
            echo -e "  ${RED}✗${NC} No instances or access denied"
        fi
        echo ""
    done
    
    if [ $profile_instances -gt 0 ]; then
        accounts_with_instances=$((accounts_with_instances + 1))
        total_instances=$((total_instances + profile_instances))
        echo -e "${GREEN}Profile $profile: $profile_instances instances${NC}"
    fi
    echo ""
done

echo -e "${BLUE}=== FINAL SUMMARY ===${NC}"
echo -e "${GREEN}Total profiles checked: ${#profiles[@]}${NC}"
echo -e "${GREEN}Accounts with instances: $accounts_with_instances${NC}"
echo -e "${GREEN}Total instances found: $total_instances${NC}"

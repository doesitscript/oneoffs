#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TARGET_IP="10.62.16.141"

echo -e "${BLUE}=== Searching for EC2 Instance with IP: $TARGET_IP ===${NC}"
echo ""

# Get all profiles dynamically
profiles=($(aws configure list-profiles))
regions=("us-east-2" "us-west-2")
found=false

for profile in "${profiles[@]}"; do
    for region in "${regions[@]}"; do
        # Get detailed instance information including IP addresses
        instances=$(aws ec2 describe-instances \
            --profile "$profile" \
            --region "$region" \
            --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PrivateIpAddress,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
            --output text 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$instances" ]; then
            echo "$instances" | while read -r instance_id state instance_type private_ip public_ip name; do
                if [ "$instance_id" != "None" ] && [ -n "$instance_id" ]; then
                    if [ "$private_ip" = "$TARGET_IP" ] || [ "$public_ip" = "$TARGET_IP" ]; then
                        echo -e "${GREEN}🎯 FOUND INSTANCE!${NC}"
                        echo -e "${BLUE}Profile:${NC} $profile"
                        echo -e "${BLUE}Region:${NC} $region"
                        echo -e "${BLUE}Instance ID:${NC} $instance_id"
                        echo -e "${BLUE}State:${NC} $state"
                        echo -e "${BLUE}Type:${NC} $instance_type"
                        echo -e "${BLUE}Private IP:${NC} $private_ip"
                        echo -e "${BLUE}Public IP:${NC} $public_ip"
                        echo -e "${BLUE}Name:${NC} $name"
                        echo ""
                        found=true
                    fi
                fi
            done
        fi
    done
done

if [ "$found" = false ]; then
    echo -e "${RED}❌ No instance found with IP address: $TARGET_IP${NC}"
    echo -e "${YELLOW}This IP might be:${NC}"
    echo "  - A different type of AWS resource (RDS, ELB, etc.)"
    echo "  - An on-premises resource"
    echo "  - A resource in a different region"
    echo "  - A resource that was terminated"
fi

#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TARGET_IP="10.62.16.141"

echo -e "${BLUE}=== Searching for AWS Resource with IP: $TARGET_IP ===${NC}"
echo ""

# Get all profiles dynamically
profiles=($(aws configure list-profiles))
regions=("us-east-2" "us-west-2")
found=false

for profile in "${profiles[@]}"; do
    for region in "${regions[@]}"; do
        echo -e "${YELLOW}Checking $profile in $region...${NC}"
        
        # Check RDS instances
        rds_instances=$(aws rds describe-db-instances \
            --profile "$profile" \
            --region "$region" \
            --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address,DBInstanceClass]' \
            --output text 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$rds_instances" ]; then
            echo "$rds_instances" | while read -r db_id status endpoint class; do
                if [ "$endpoint" = "$TARGET_IP" ]; then
                    echo -e "${GREEN}🎯 FOUND RDS INSTANCE!${NC}"
                    echo -e "${BLUE}Profile:${NC} $profile"
                    echo -e "${BLUE}Region:${NC} $region"
                    echo -e "${BLUE}DB ID:${NC} $db_id"
                    echo -e "${BLUE}Status:${NC} $status"
                    echo -e "${BLUE}Endpoint:${NC} $endpoint"
                    echo -e "${BLUE}Class:${NC} $class"
                    echo ""
                    found=true
                fi
            done
        fi
        
        # Check Load Balancers
        elb_instances=$(aws elbv2 describe-load-balancers \
            --profile "$profile" \
            --region "$region" \
            --query 'LoadBalancers[*].[LoadBalancerName,State.Code,DNSName,Type]' \
            --output text 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$elb_instances" ]; then
            echo "$elb_instances" | while read -r lb_name state dns_name type; do
                # Resolve DNS to IP and check
                resolved_ip=$(nslookup "$dns_name" 2>/dev/null | grep "Address:" | tail -1 | awk '{print $2}')
                if [ "$resolved_ip" = "$TARGET_IP" ]; then
                    echo -e "${GREEN}🎯 FOUND LOAD BALANCER!${NC}"
                    echo -e "${BLUE}Profile:${NC} $profile"
                    echo -e "${BLUE}Region:${NC} $region"
                    echo -e "${BLUE}LB Name:${NC} $lb_name"
                    echo -e "${BLUE}State:${NC} $state"
                    echo -e "${BLUE}DNS:${NC} $dns_name"
                    echo -e "${BLUE}Type:${NC} $type"
                    echo -e "${BLUE}Resolved IP:${NC} $resolved_ip"
                    echo ""
                    found=true
                fi
            done
        fi
        
        # Check Network Interfaces
        eni_instances=$(aws ec2 describe-network-interfaces \
            --profile "$profile" \
            --region "$region" \
            --query 'NetworkInterfaces[*].[NetworkInterfaceId,Status,PrivateIpAddress,Description]' \
            --output text 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$eni_instances" ]; then
            echo "$eni_instances" | while read -r eni_id status private_ip description; do
                if [ "$private_ip" = "$TARGET_IP" ]; then
                    echo -e "${GREEN}🎯 FOUND NETWORK INTERFACE!${NC}"
                    echo -e "${BLUE}Profile:${NC} $profile"
                    echo -e "${BLUE}Region:${NC} $region"
                    echo -e "${BLUE}ENI ID:${NC} $eni_id"
                    echo -e "${BLUE}Status:${NC} $status"
                    echo -e "${BLUE}Private IP:${NC} $private_ip"
                    echo -e "${BLUE}Description:${NC} $description"
                    echo ""
                    found=true
                fi
            done
        fi
    done
done

if [ "$found" = false ]; then
    echo -e "${RED}❌ No AWS resource found with IP address: $TARGET_IP${NC}"
    echo -e "${YELLOW}This IP might be:${NC}"
    echo "  - An on-premises resource"
    echo "  - A resource in a different region (not us-east-2 or us-west-2)"
    echo "  - A resource that was terminated/deleted"
    echo "  - A resource in a different AWS account"
    echo "  - A NAT Gateway or VPC endpoint"
    echo ""
    echo -e "${YELLOW}You can also try:${NC}"
    echo "  - Checking other regions (us-east-1, us-west-1, etc.)"
    echo "  - Using 'nslookup $TARGET_IP' to see if it resolves to a hostname"
    echo "  - Checking your on-premises network documentation"
fi

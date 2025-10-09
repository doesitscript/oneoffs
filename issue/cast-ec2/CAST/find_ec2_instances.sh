#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== EC2 Instance Search Across All Accounts ===${NC}"
echo -e "${YELLOW}Searching us-east-2 and us-west-2 regions${NC}"
echo ""

# Array of profiles to check
profiles=(
    "CASTSoftware_dev_925774240130_admin"
    "AFT_474668427263_admin"
    "Audit_825765384428_admin"
    "Backup_Admin_448049813044_admin"
    "Central_Backup_Vault_443370695612_admin"
    "Central_KMS_Vault_976193251493_admin"
    "Certificates_Mgmt_373317459136_admin"
    "CloudOperations_920411896753_admin"
    "DataAnalyticsDev_285529797488_admin"
    "FinOps_203236040739_admin"
    "Identity_Center_717279730613_admin"
    "IgelUmsDev_273268177664_admin"
    "IgelUmsProd_486295461085_admin"
    "InfrastructureObservability_837098208196_admin"
    "InfrastructureObservabilityDev_836217041434_admin"
    "InfrastructureSharedServices_185869891420_admin"
    "InfrastructureSharedServicesDev_015647311640_admin"
    "Log_Archive_463470955493_admin"
    "MasterDataManagement_dev_981686515035_admin"
    "Migration_Tooling_210519480272_admin"
    "Network_Hub_207567762220_admin"
    "Security_Tooling_794038215373_admin"
    "SharedServices_Harness_807379992595_admin"
    "SharedServices_SRE_795438191304_admin"
    "SharedServices_imagemanagement_422228628991_admin"
    "StackSet_Integrations_239658749012_admin"
    "WellArchitectedFramework_860829110296_admin"
)

regions=("us-east-2" "us-west-2")
total_instances=0

for profile in "${profiles[@]}"; do
    echo -e "${GREEN}=== Checking Profile: $profile ===${NC}"
    
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
                    ((total_instances++))
                fi
            done
        else
            echo -e "  ${RED}✗${NC} No instances or access denied"
        fi
        echo ""
    done
    echo ""
done

echo -e "${BLUE}=== SUMMARY ===${NC}"
echo -e "${GREEN}Total instances found: $total_instances${NC}"

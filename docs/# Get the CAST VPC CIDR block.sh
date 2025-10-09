# Get the CAST VPC CIDR block
aws ec2 describe-vpcs --profile CASTSoftware_dev_925774240130_admin \
  --filters "Name=tag:Name,Values=castsoftwaredev" \
  --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value]' \
  --output table

# Get all subnets in the CAST VPC
aws ec2 describe-subnets --profile CASTSoftware_dev_925774240130_admin \
  --filters "Name=vpc-id,Values=vpc-030d39057ed8fa1b5" \
  --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,Tags[?Key==`Name`].Value]' \
  --output table


##### IPAM #####
# Get IPAM pools and their CIDR ranges
aws ec2 describe-ipam-pools --profile Network_Hub_207567762220_admin \
  --query 'IpamPools[*].[IpamPoolId,Description,AddressFamily,State,AllocatedResourceCidrs]' \
  --output table

# Get IPAM scopes
aws ec2 describe-ipam-scopes --profile Network_Hub_207567762220_admin \
  --query 'IpamScopes[*].[IpamScopeId,Description,State]' \
  --output table

# Get IPAM resource discoveries
aws ec2 describe-ipam-resource-discoveries --profile Network_Hub_207567762220_admin \
  --query 'IpamResourceDiscoveries[*].[IpamResourceDiscoveryId,Description,State]' \
  --output table
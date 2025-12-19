make awsutils-config-update
make aws-sso-list-profiles

use my aws profiles when needed below. I'm already signed in to aws using my aws profiles.

Can you check that these created accounts (these are short names for what their full names are in aws)
sectigo-dev
sectigo-qa
sectigo-prd
db2dataconnect-dev
db2dataconnect-prd
database-sandbox
varonis-prd
EnterpriseArchitecture-sandbox
AwsInfrastructure-sandbox
use the matching account profile to perfrom research to answer these questions using aws and to check terraform locally
Profile list: issue/aft-review-sectigo-batch/profiles.sh

for each of these accounts
find the admin account name from: /Users/a805120/develop/aws-access/conf/sso_groups.yaml
the account names above are substrings of the admin groups in the file above and substring of the actual account name in aws organizations
get the correct accountid from my profile.sh above too, use the name above to match the profile to use, that profile also will have the account name in the profile name

ensure in identity center: (use my profile Identity_Center_717279730613_admin)
1. there is a group that matches what is in sso_groups.yaml
2 tell me if any users are in the group in identity center

In each account ensure that there is networking and subnets and security groups


Use the tools from these mcp servers for your investigation, don't fix anything:
awslabs.ccapi-mcp-server, terraform-mcp-server-local, awslabs.terraform-mcp-server

# Development variables for CAST 
# Account Configuration
account_id = "925774240130"
profile    = "CASTSoftware_dev_925774240130_admin"
region     = "us-east-2"

# Instance Configuration
instance_type    = "r5a.24xlarge"
ami_id           = "ami-0684b1bd72f4b0d55" # Microsoft Windows Server 2022 Base (us-east-2)
cast_allowed_ips = []                      # TODO: Depricating, not this granular since TOm will be on a thin client

allowed_cidr_blocks = [
#   "0.0.0.0/0", # TODO:for first test; wide open

"10.0.0.0/8" # on-premises network range
# "10.1.0.0/16" # need our on-prem cidrs to replace /8 (16 mil addresses). For prod or audit requirements
# "10.2.0.0/16" # on-premises network range

### For AFT accounts that default traffic to the firewall. Add in addition to /8 cidr above
"10.62.0.0/24"         # By default all traffic goes throughVPC GWLB for inspection. Check with Ben/Stephen if this is implemented
"10.62.1.0/24"         # Enable inbound traffic coming from On Prem and Internet via Direct Connect  -> Inspection-Inbound VPC; RDP from thin clients or physically on prem. 
"10.62.9.0/24"         # Hub handling traffic between AWS accounts; AWS based shared services, ie monitoring, SCSM, SCOM?, Ansible ran in aws;Centralized-Inbound VPC
"10.62.10.0/24"        # AD name resolation, domain joins, **communicating to SSM if we manage this instance though ssm. we're using 0.0.0.0/0 on the fist iteration, this should be enabled after disabled that. Required if Packer doesn't overwrite DHCP options for DNS. Base AMI defaults to AmazonProvidedDNS (Route 53 ) # TODO: if something breaks related todns see: cat /etc/resolv.conf or Get-DnsClientServerAddress
"10.62.20.0/24"        # vpc traffic
]

# Naming Convention
project_name = "cast-software-dev"
environment  = "dev"



# =============================================================================
# DEVELOPMENT VARIABLES FOR CAST EC2
# =============================================================================

# Account Configuration
account_id   = "925774240130"
profile      = "CASTSoftware_dev_925774240130_admin"
region       = "us-east-2"
region_short = "u2e"
app          = "castsoftware"
env          = "dev"

# Instance Configuration
instance_type    = "r5a.24xlarge"
ami_id           = "ami-0684b1bd72f4b0d55" # Microsoft Windows Server 2022 Base (us-east-2)
cast_allowed_ips = []                      # TODO: Deprecated, client has thin client and can rdp

# Network Access Configuration
allowed_cidr_blocks = [
  # "0.0.0.0/0", # TODO: for first test; wide open
  "10.0.0.0/8" # on-premises network range
  # "10.1.0.0/16" # need our on-prem cidrs to replace /8 (16 mil addresses). For prod or audit requirements; example
  # "10.2.0.0/16" # on-premises network range; example
]

# AFT Account CIDR blocks for firewall traffic
aft_allowed_cidr_blocks = [
  # For AFT accounts that default traffic to the firewall. Add in addition to /8 cidr above
  "10.62.0.0/24",  # By default all traffic goes through VPC GWLB for inspection. Check with Ben/Stephen if this is implemented
  "10.62.1.0/24",  # Enable inbound traffic coming from On Prem and Internet via Direct Connect -> Inspection-Inbound VPC; RDP from thin clients or physically on prem
  "10.62.9.0/24",  # Hub handling traffic between AWS accounts; AWS based shared services, ie monitoring, SCSM, SCOM?, Ansible ran in aws; Centralized-Inbound VPC
  "10.62.10.0/24", # AD name resolution, domain joins, **communicating to SSM if we manage this instance through ssm. we're using 0.0.0.0/0 on the first iteration, this should be enabled after disabled that. Required if Packer doesn't overwrite DHCP options for DNS. Base AMI defaults to AmazonProvidedDNS (Route 53) # TODO: if something breaks related to dns see: cat /etc/resolv.conf or Get-DnsClientServerAddress
  "10.62.20.0/24"  # vpc traffic
]

# Volume Configuration
root_volume_size       = 100
root_volume_type       = "gp3"
root_volume_iops       = 3000
root_volume_throughput = 125

data_volume_size        = 500
data_volume_type        = "gp3"
data_volume_iops        = 4000
data_volume_throughput  = 250
data_volume_device_name = "/dev/sdf"

# Instance Settings
enable_public_ip        = false
enable_ebs_optimization = true
enable_encryption       = true

# Naming Convention
project_name = "cast-software-dev"
environment  = "dev"

# Additional Tags
tags = {
  Owner      = "CAST Team"
  CostCenter = "Engineering"
  Backup     = "Daily"
  Monitoring = "Enabled"
}



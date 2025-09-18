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
  "0.0.0.0/0", # TODO: Remove this, test value
  "10.0.0.0/8",
]

# Naming Convention
project_name = "cast-software-dev"
environment  = "dev"



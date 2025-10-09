# Development variables for CAST Software Dev account
# This file contains variable values for the development environment

# Account Configuration
account_id = "925774240130"
profile    = "CASTSoftware_dev_925774240130_admin"
region     = "us-east-2"

# Instance Configuration
instance_type = "r5a.24xlarge"
ami_id        = "ami-0684b1bd72f4b0d55" # Amazon Linux 2 AMI (us-east-1)

# Naming Convention
project_name = "cast-software-dev"
environment  = "dev"

# Tags
common_tags = {
  Project     = "CAST-EC2"
  Environment = "Development"
  ManagedBy   = "Terraform"
  Owner       = "CAST Software"
}

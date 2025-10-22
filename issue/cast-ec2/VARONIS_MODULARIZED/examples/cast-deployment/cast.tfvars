# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
# Version 1.0.0

# CAST EC2 Deployment Configuration
# Replace these values with your actual CAST account configuration

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================

# VPC and Subnet IDs - Replace with actual CAST account values
vpc_id    = "vpc-xxxxxxxx"    # Replace with CAST VPC ID
subnet_id = "subnet-xxxxxxxx" # Replace with CAST subnet ID

# =============================================================================
# AMI CONFIGURATION
# =============================================================================

# AMI ID for CAST instance - Replace with actual CAST AMI
ami_id = "ami-xxxxxxxx" # Replace with CAST AMI ID

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

# Allowed CIDR blocks for CAST access
allowed_cidr_blocks = [
  "10.0.0.0/8",     # Corporate network
  "192.168.0.0/16", # Additional network if needed
  # Add your specific IP ranges here
]

# =============================================================================
# APPLICATION CONFIGURATION
# =============================================================================

# Secrets Manager ARNs for CAST application
secrets_manager_arns = [
  # "arn:aws:secretsmanager:us-east-2:123456789012:secret:CAST-Secret-abc123",
  # Add your CAST-specific secrets here
]

# SSM Parameter ARNs for CAST application
ssm_parameter_arns = [
  # "arn:aws:ssm:us-east-2:123456789012:parameter/CAST/Config",
  # Add your CAST-specific parameters here
]

# User data for CAST instance initialization
user_data = "brd03w255,prod" # Replace with CAST-specific user data

# =============================================================================
# TAGGING
# =============================================================================

tags = {
  Project     = "CAST"
  Application = "CAST Software"
  Environment = "Production"
  Owner       = "CAST Team"
  CostCenter  = "Development"
  ManagedBy   = "Terraform"
}

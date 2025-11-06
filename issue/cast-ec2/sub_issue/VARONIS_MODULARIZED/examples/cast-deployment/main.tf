# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
# Version 1.0.0

# CAST EC2 Deployment using the refactored Varonis module
# This example shows how to deploy a CAST instance using the parameterized module

module "cast_instance" {
  source = "../../"

  # Required variables
  app_name    = "cast"
  environment = "prod"
  vpc_id      = var.vpc_id
  subnet_id   = var.subnet_id

  # Instance configuration
  instance_type = "r5a.24xlarge" # CAST-specific instance type
  ami_id        = var.ami_id     # CAST-specific AMI

  # Storage configuration
  root_volume_size = 100
  root_volume_type = "gp3"
  additional_volumes = [
    {
      device_name = "/dev/sdf"
      size        = 500
      type        = "gp3"
      encrypted   = true
    }
  ]

  # Security configuration
  allowed_cidr_blocks = var.allowed_cidr_blocks
  rdp_port            = 3389
  https_port          = 443

  # IAM configuration - CAST-specific secrets and parameters
  secrets_manager_arns = var.secrets_manager_arns
  ssm_parameter_arns   = var.ssm_parameter_arns

  # Instance behavior
  disable_api_termination    = true
  enable_detailed_monitoring = true
  enable_ebs_optimization    = true

  # SSH key management
  enable_ssh_key_generation = true
  ssh_key_name              = "cast-prod-key"

  # User data for CAST-specific configuration
  user_data = var.user_data

  # CAST-specific tags
  tags = merge(var.tags, {
    Project     = "CAST"
    Application = "CAST Software"
    Owner       = "CAST Team"
    CostCenter  = "Development"
  })
}

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
# Version 1.0.0

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

variable "app_name" {
  description = "Name of the application (e.g., varonis, cast)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "vpc_id" {
  description = "VPC ID where the instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be deployed"
  type        = string
}

# =============================================================================
# INSTANCE CONFIGURATION
# =============================================================================

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.8xlarge"

  validation {
    condition     = can(regex("^[a-z0-9]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "Instance type must be a valid AWS instance type."
  }
}

variable "ami_id" {
  description = "AMI ID for the instance. If not provided, will use latest Windows AMI from specified owner"
  type        = string
  default     = null
}

variable "ami_owner" {
  description = "AWS account ID that owns the AMI (used when ami_id is not specified)"
  type        = string
  default     = "422228628991" # customer-image-mgmt account
}

variable "ami_name_filter" {
  description = "AMI name filter pattern (used when ami_id is not specified)"
  type        = string
  default     = "amidistribution*"
}

variable "user_data" {
  description = "User data script for instance initialization"
  type        = string
  default     = ""
}

# =============================================================================
# STORAGE CONFIGURATION
# =============================================================================

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 250

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 16384
    error_message = "Root volume size must be between 8 and 16384 GB."
  }
}

variable "root_volume_type" {
  description = "Type of root volume (gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "Root volume type must be one of: gp2, gp3, io1, io2."
  }
}

variable "additional_volumes" {
  description = "List of additional EBS volumes to attach"
  type = list(object({
    device_name = string
    size        = number
    type        = string
    encrypted   = optional(bool, true)
  }))
  default = [
    {
      device_name = "/dev/sdf"
      size        = 500
      type        = "gp3"
      encrypted   = true
    }
  ]
}

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the instance"
  type        = list(string)
  default     = ["10.0.0.0/8"]

  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid IP address ranges."
  }
}

variable "rdp_port" {
  description = "RDP port number"
  type        = number
  default     = 3389
}

variable "https_port" {
  description = "HTTPS port number"
  type        = number
  default     = 443
}

variable "enable_ssh_key_generation" {
  description = "Whether to generate and store SSH key in Secrets Manager"
  type        = bool
  default     = true
}

variable "ssh_key_name" {
  description = "Name for the SSH key pair (used when enable_ssh_key_generation is true)"
  type        = string
  default     = null
}

# =============================================================================
# IAM CONFIGURATION
# =============================================================================

variable "additional_iam_policies" {
  description = "List of additional IAM policy ARNs to attach to the instance role"
  type        = list(string)
  default     = []
}

variable "secrets_manager_arns" {
  description = "List of Secrets Manager ARNs the instance can access"
  type        = list(string)
  default     = []
}

variable "ssm_parameter_arns" {
  description = "List of SSM Parameter ARNs the instance can access"
  type        = list(string)
  default     = []
}

# =============================================================================
# INSTANCE BEHAVIOR
# =============================================================================

variable "disable_api_termination" {
  description = "Whether to disable API termination for the instance"
  type        = bool
  default     = true
}

variable "enable_detailed_monitoring" {
  description = "Whether to enable detailed monitoring for the instance"
  type        = bool
  default     = false
}

variable "enable_ebs_optimization" {
  description = "Whether to enable EBS optimization for the instance"
  type        = bool
  default     = true
}

# =============================================================================
# TAGGING
# =============================================================================

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "resource_suffix" {
  description = "Suffix to append to resource names"
  type        = string
  default     = "instance"
}

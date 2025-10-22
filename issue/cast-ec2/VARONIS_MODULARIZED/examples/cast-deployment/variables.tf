# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
# Version 1.0.0

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

variable "vpc_id" {
  description = "VPC ID where the CAST instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the CAST instance will be deployed"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the CAST instance"
  type        = string
}

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the CAST instance"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# =============================================================================
# APPLICATION CONFIGURATION
# =============================================================================

variable "secrets_manager_arns" {
  description = "List of Secrets Manager ARNs the CAST instance can access"
  type        = list(string)
  default     = []
}

variable "ssm_parameter_arns" {
  description = "List of SSM Parameter ARNs the CAST instance can access"
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "User data script for CAST instance initialization"
  type        = string
  default     = ""
}

# =============================================================================
# TAGGING
# =============================================================================

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

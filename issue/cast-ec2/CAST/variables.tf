# =============================================================================
# CAST EC2 VARIABLES
# =============================================================================

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the CAST EC2 instance via RDP/SSH"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid IP address ranges."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the CAST instance"
  type        = string
  default     = "r5a.24xlarge"

  validation {
    condition     = can(regex("^[a-z0-9]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "Instance type must be a valid AWS instance type."
  }
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 100

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 16384
    error_message = "Root volume size must be between 8 and 16384 GB."
  }
}

variable "data_volume_size" {
  description = "Size of the additional data EBS volume in GB"
  type        = number
  default     = 500

  validation {
    condition     = var.data_volume_size >= 1 && var.data_volume_size <= 16384
    error_message = "Data volume size must be between 1 and 16384 GB."
  }
}

variable "enable_public_ip" {
  description = "Whether to assign a public IP to the instance"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "cast-ec2"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

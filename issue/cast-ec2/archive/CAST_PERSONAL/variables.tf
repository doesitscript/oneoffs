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

# =============================================================================
# ADDITIONAL VARIABLES FOR CAST EC2
# =============================================================================

variable "account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "925774240130"
}

variable "profile" {
  description = "AWS Profile to use"
  type        = string
  default     = "CASTSoftware_dev_925774240130_admin"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

variable "region_short" {
  description = "Short region identifier"
  type        = string
  default     = "u2e"
}

variable "app" {
  description = "Application name"
  type        = string
  default     = "castsoftware"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0684b1bd72f4b0d55"
}

variable "cast_allowed_ips" {
  description = "List of IP addresses allowed to access CAST instance (deprecated, use allowed_cidr_blocks)"
  type        = list(string)
  default     = []
}

variable "aft_allowed_cidr_blocks" {
  description = "List of CIDR blocks for AFT accounts that default traffic to firewall"
  type        = list(string)
  default     = []
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

variable "root_volume_iops" {
  description = "IOPS for root volume (only applicable for io1, io2, gp3)"
  type        = number
  default     = 3000

  validation {
    condition     = var.root_volume_iops >= 100 && var.root_volume_iops <= 16000
    error_message = "Root volume IOPS must be between 100 and 16000."
  }
}

variable "root_volume_throughput" {
  description = "Throughput for root volume in MiB/s (only applicable for gp3)"
  type        = number
  default     = 125

  validation {
    condition     = var.root_volume_throughput >= 125 && var.root_volume_throughput <= 1000
    error_message = "Root volume throughput must be between 125 and 1000 MiB/s."
  }
}

variable "data_volume_type" {
  description = "Type of data volume (gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.data_volume_type)
    error_message = "Data volume type must be one of: gp2, gp3, io1, io2."
  }
}

variable "data_volume_iops" {
  description = "IOPS for data volume (only applicable for io1, io2, gp3)"
  type        = number
  default     = 4000

  validation {
    condition     = var.data_volume_iops >= 100 && var.data_volume_iops <= 16000
    error_message = "Data volume IOPS must be between 100 and 16000."
  }
}

variable "data_volume_throughput" {
  description = "Throughput for data volume in MiB/s (only applicable for gp3)"
  type        = number
  default     = 250

  validation {
    condition     = var.data_volume_throughput >= 125 && var.data_volume_throughput <= 1000
    error_message = "Data volume throughput must be between 125 and 1000 MiB/s."
  }
}

variable "data_volume_device_name" {
  description = "Device name for the data volume"
  type        = string
  default     = "/dev/sdf"
}

variable "enable_ebs_optimization" {
  description = "Enable EBS optimization for the instance"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable encryption for EBS volumes"
  type        = bool
  default     = true
}

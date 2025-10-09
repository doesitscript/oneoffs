locals {
  # Use variables instead of hardcoded values
  account_id   = var.account_id
  profile      = var.profile
  region       = var.region
  region_short = var.region_short
  app          = var.app
  env          = var.env

  # Tags
  common_tags = merge(
    {
      Project     = local.app
      Environment = local.env
      ManagedBy   = "Terraform"
      Owner       = "CAST Team"
    },
    var.tags
  )
}

#TODO for debugging
data "aws_caller_identity" "current" {}

data "aws_vpc" "default_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${local.app}${local.env}"]
  }
}

data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

# Get details of the selected subnet
data "aws_subnet" "selected_subnet" {
  id = local.default_vpc_subnet_id
}

locals {
  # There's an open issue on aft-account-request track what we need to implement in aws (ie set default subnet at account vending )
  # or we could select subnet by az
  default_vpc_subnet_id   = data.aws_subnets.default_vpc_subnets.ids[0]
  all_allowed_cidr_blocks = concat(var.aft_allowed_cidr_blocks, var.allowed_cidr_blocks)
}


resource "aws_security_group" "base" {
  name_prefix = "cast-ec2-sg-base"
  description = "Security group for allowing all corporate originated traffic"
  vpc_id      = data.aws_vpc.default_vpc.id

  # All inbound traffic from on-premises networks
  ingress {
    description = "Bread network traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # All outbound traffic to the internet
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "default" {
  name_prefix = "cast-ec2-sg-default"
  description = "Standard per app excepts base security group"
  vpc_id      = data.aws_vpc.default_vpc.id

  # SSH access from allowed CIDR blocks
  ingress {
    description = "SSH access from CAST allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.all_allowed_cidr_blocks
  }

  # RDP access from allowed CIDR blocks
  ingress {
    description = "RDP access from CAST allowed IPs"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = local.all_allowed_cidr_blocks
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "cast-ec2-security-group"
  })
}


resource "aws_security_group" "aft_default_customization_compatibility" {
  name_prefix = "cast-ec2-sg-aft-default-customization-compatibility"
  description = "Security group for vpcs  that have default configuration directing traffic to firewall by default."
  vpc_id      = data.aws_vpc.default_vpc.id

  dynamic "egress" {
    for_each = local.all_allowed_cidr_blocks
    content {
      description = "Allow outbound to ${egress.value}"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [egress.value]
    }
  }

  dynamic "ingress" {
    for_each = local.all_allowed_cidr_blocks
    content {
      description = "Allow inbound from ${ingress.value}"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [ingress.value]
    }
  }

}

# TODO: document The r5a.24xlarge instance is in the Memory optimized family with 96 vCPUs, 768 GiB of memory and 20 Gibps of bandwidth starting at $5.424 per hour.
# resource "aws_instance" "cast_ec2" {
#   # count                       = 0
#   ami                         = var.ami_id
#   instance_type               = var.instance_type
#   vpc_security_group_ids      = [aws_security_group.aft_default_customization_compatibility.id]
#   subnet_id                   = local.default_vpc_subnet_id
#   associate_public_ip_address = var.enable_public_ip

#   # Enable EBS optimization for better performance
#   ebs_optimized = var.enable_ebs_optimization

#   # Root volume configuration
#   root_block_device {
#     volume_type           = var.root_volume_type
#     volume_size           = var.root_volume_size
#     iops                  = var.root_volume_iops
#     throughput            = var.root_volume_throughput
#     encrypted             = var.enable_encryption
#     delete_on_termination = true

#     tags = merge(local.common_tags, {
#       Name = "cast-ec2-root-volume"
#       Type = "Root"
#     })
#   }

#   # Additional data volume
#   ebs_block_device {
#     device_name = var.data_volume_device_name
#     volume_type = var.data_volume_type
#     volume_size = var.data_volume_size
#     iops        = var.data_volume_iops
#     throughput  = var.data_volume_throughput
#     encrypted   = var.enable_encryption

#     tags = merge(local.common_tags, {
#       Name = "cast-ec2-data-volume"
#       Type = "Data"
#     })
#   }

#   tags = merge(local.common_tags, {
#     Name = "${local.app}-${local.env}-ec2"
#     Type = "EC2-Instance"
#   })
# }

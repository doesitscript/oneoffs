# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
# Version 1.0.0

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    Name        = "${var.app_name}-${var.environment}-${var.resource_suffix}"
    Environment = var.environment
    Application = var.app_name
    ManagedBy   = "Terraform"
    CreatedBy   = "${var.app_name}-EC2-Module"
  })

  # Generate SSH key name if not provided
  ssh_key_name = var.ssh_key_name != null ? var.ssh_key_name : "${var.app_name}-key-${var.environment}"
}

# =============================================================================
# SSH KEY GENERATION (OPTIONAL)
# =============================================================================

# Generate SSH Key (only if enabled)
resource "tls_private_key" "ssh_key" {
  count     = var.enable_ssh_key_generation ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Store SSH Key in Secrets Manager (only if enabled)
resource "aws_secretsmanager_secret" "ssh_private_key" {
  count                   = var.enable_ssh_key_generation ? 1 : 0
  name                    = "${var.app_name}-ssh-key-${var.environment}"
  description             = "SSH private key for ${var.app_name} instance"
  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-ssh-key"
  })
}

resource "aws_secretsmanager_secret_version" "ssh_private_key" {
  count         = var.enable_ssh_key_generation ? 1 : 0
  secret_id     = aws_secretsmanager_secret.ssh_private_key[0].id
  secret_string = tls_private_key.ssh_key[0].private_key_openssh
}

# Create Key Pair (only if SSH key generation is enabled)
resource "aws_key_pair" "app_key" {
  count      = var.enable_ssh_key_generation ? 1 : 0
  key_name   = local.ssh_key_name
  public_key = tls_private_key.ssh_key[0].public_key_openssh

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-key"
  })
}

# =============================================================================
# AMI SELECTION
# =============================================================================

# Find latest Windows AMI (only if ami_id is not provided)
data "aws_ami" "windows_ami" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "platform"
    values = ["windows"]
  }
}

# =============================================================================
# SECURITY GROUP
# =============================================================================

resource "aws_security_group" "app_sg" {
  name        = "${var.app_name}-sg-${var.environment}"
  description = "Security Group for ${var.app_name} instance"
  vpc_id      = var.vpc_id

  # RDP access
  ingress {
    description = "RDP"
    from_port   = var.rdp_port
    to_port     = var.rdp_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
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
    Name = "${var.app_name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# IAM ROLE AND POLICIES
# =============================================================================

# IAM Role
resource "aws_iam_role" "app_role" {
  name = "${var.app_name}-role-${var.environment}-${local.region}"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-role"
  })
}

# Attach SSM Core policy
resource "aws_iam_role_policy_attachment" "ssm_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.app_role.name
}

# CloudWatch Logs Policy
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "${var.app_name}-cloudwatch-policy-${var.environment}-${local.region}"
  description = "Policy for CloudWatch Logs access for ${var.app_name} instance"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/${var.app_name}/*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-cloudwatch-policy"
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
  role       = aws_iam_role.app_role.name
}

# Secrets Manager access policy (if secrets are specified)
resource "aws_iam_policy" "secrets_access_policy" {
  count       = length(var.secrets_manager_arns) > 0 ? 1 : 0
  name        = "${var.app_name}-secrets-policy-${var.environment}-${local.region}"
  description = "Policy for Secrets Manager access for ${var.app_name} instance"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secrets_manager_arns
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-secrets-policy"
  })
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
  count      = length(var.secrets_manager_arns) > 0 ? 1 : 0
  policy_arn = aws_iam_policy.secrets_access_policy[0].arn
  role       = aws_iam_role.app_role.name
}

# SSM Parameter access policy (if parameters are specified)
resource "aws_iam_policy" "ssm_parameter_policy" {
  count       = length(var.ssm_parameter_arns) > 0 ? 1 : 0
  name        = "${var.app_name}-ssm-policy-${var.environment}-${local.region}"
  description = "Policy for SSM Parameter access for ${var.app_name} instance"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = var.ssm_parameter_arns
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-ssm-policy"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_parameter" {
  count      = length(var.ssm_parameter_arns) > 0 ? 1 : 0
  policy_arn = aws_iam_policy.ssm_parameter_policy[0].arn
  role       = aws_iam_role.app_role.name
}

# Attach additional IAM policies if specified
resource "aws_iam_role_policy_attachment" "additional_policies" {
  count      = length(var.additional_iam_policies)
  policy_arn = var.additional_iam_policies[count.index]
  role       = aws_iam_role.app_role.name
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.app_name}-profile-${var.environment}-${local.region}"
  role = aws_iam_role.app_role.name

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-profile"
  })
}

# =============================================================================
# EC2 INSTANCE
# =============================================================================

resource "aws_instance" "app_instance" {
  ami                    = var.ami_id != null ? var.ami_id : data.aws_ami.windows_ami[0].id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.app_profile.name
  key_name               = var.enable_ssh_key_generation ? aws_key_pair.app_key[0].key_name : null
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # User data for initial configuration
  user_data = var.user_data

  # Enable EBS optimization if supported by instance type
  ebs_optimized = var.enable_ebs_optimization

  # Enable detailed monitoring
  monitoring = var.enable_detailed_monitoring

  # Metadata options for security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  # Disable API termination
  disable_api_termination = var.disable_api_termination

  # Root volume configuration
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = true
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = "${var.app_name}-c-drive"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-instance"
  })

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

# =============================================================================
# ADDITIONAL EBS VOLUMES
# =============================================================================

# Create additional EBS volumes
resource "aws_ebs_volume" "additional_volumes" {
  for_each = { for vol in var.additional_volumes : vol.device_name => vol }

  availability_zone = aws_instance.app_instance.availability_zone
  size              = each.value.size
  type              = each.value.type
  encrypted         = each.value.encrypted

  tags = merge(local.common_tags, {
    Name = "${var.app_name}-${each.key}-drive"
  })
}

# Attach additional volumes
resource "aws_volume_attachment" "additional_volumes" {
  for_each = { for vol in var.additional_volumes : vol.device_name => vol }

  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.additional_volumes[each.key].id
  instance_id = aws_instance.app_instance.id
}

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
# Version 1.0.0

# =============================================================================
# INSTANCE OUTPUTS
# =============================================================================

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_instance.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.app_instance.arn
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.app_instance.private_ip
}

output "instance_public_ip" {
  description = "Public IP address of the instance (if applicable)"
  value       = aws_instance.app_instance.public_ip
}

output "instance_private_dns" {
  description = "Private DNS name of the instance"
  value       = aws_instance.app_instance.private_dns
}

output "instance_public_dns" {
  description = "Public DNS name of the instance (if applicable)"
  value       = aws_instance.app_instance.public_dns
}

output "instance_availability_zone" {
  description = "Availability zone where the instance is deployed"
  value       = aws_instance.app_instance.availability_zone
}

output "instance_state" {
  description = "Current state of the instance"
  value       = aws_instance.app_instance.instance_state
}

output "instance_type" {
  description = "Instance type of the EC2 instance"
  value       = aws_instance.app_instance.instance_type
}

output "instance_ami" {
  description = "AMI ID used for the instance"
  value       = aws_instance.app_instance.ami
}

# =============================================================================
# SECURITY OUTPUTS
# =============================================================================

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_sg.id
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.app_sg.arn
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.app_sg.name
}

# =============================================================================
# IAM OUTPUTS
# =============================================================================

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.app_role.arn
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.app_role.name
}

output "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.app_profile.arn
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.app_profile.name
}

# =============================================================================
# SSH KEY OUTPUTS (CONDITIONAL)
# =============================================================================

output "ssh_key_name" {
  description = "Name of the SSH key pair (if generated)"
  value       = var.enable_ssh_key_generation ? aws_key_pair.app_key[0].key_name : null
}

output "ssh_key_secret_arn" {
  description = "ARN of the SSH private key stored in Secrets Manager (if generated)"
  value       = var.enable_ssh_key_generation ? aws_secretsmanager_secret.ssh_private_key[0].arn : null
}

# =============================================================================
# STORAGE OUTPUTS
# =============================================================================

output "root_volume_id" {
  description = "ID of the root EBS volume"
  value       = aws_instance.app_instance.root_block_device[0].volume_id
}

output "additional_volume_ids" {
  description = "IDs of the additional EBS volumes"
  value       = { for k, v in aws_ebs_volume.additional_volumes : k => v.id }
}

output "volume_attachments" {
  description = "Volume attachment information"
  value = {
    for k, v in aws_volume_attachment.additional_volumes : k => {
      device_name = v.device_name
      volume_id   = v.volume_id
      instance_id = v.instance_id
    }
  }
}

# =============================================================================
# CONNECTION INFORMATION
# =============================================================================

output "connection_info" {
  description = "Connection information for the instance"
  value = {
    instance_id    = aws_instance.app_instance.id
    private_ip     = aws_instance.app_instance.private_ip
    public_ip      = aws_instance.app_instance.public_ip
    private_dns    = aws_instance.app_instance.private_dns
    public_dns     = aws_instance.app_instance.public_dns
    rdp_port       = var.rdp_port
    https_port     = var.https_port
    ssh_key_name   = var.enable_ssh_key_generation ? aws_key_pair.app_key[0].key_name : null
    security_group = aws_security_group.app_sg.name
  }
}

# =============================================================================
# DEPLOYMENT SUMMARY
# =============================================================================

output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    app_name          = var.app_name
    environment       = var.environment
    instance_id       = aws_instance.app_instance.id
    instance_type     = aws_instance.app_instance.instance_type
    availability_zone = aws_instance.app_instance.availability_zone
    vpc_id            = var.vpc_id
    subnet_id         = var.subnet_id
    security_group_id = aws_security_group.app_sg.id
    iam_role_arn      = aws_iam_role.app_role.arn
    deployment_date   = timestamp()
  }
}

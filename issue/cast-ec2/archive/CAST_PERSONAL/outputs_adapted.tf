output "instance_id" {
  description = "ID of the CAST EC2 instance"
  value       = aws_instance.cast.id
}

output "private_ip" {
  description = "Private IP address of the CAST instance"
  value       = aws_instance.cast.private_ip
}

output "public_ip" {
  description = "Public IP address of the CAST instance (if enabled)"
  value       = var.enable_public_ip ? aws_instance.cast.public_ip : null
}

output "ssh_key_secret_arn" {
  description = "ARN of the SSH private key stored in Secrets Manager"
  value       = aws_secretsmanager_secret.ssh_private_key.arn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.cast_sg.id
}

output "vpc_id" {
  description = "ID of the VPC where the instance is deployed"
  value       = data.aws_vpc.default_vpc.id
}

output "subnet_id" {
  description = "ID of the subnet where the instance is deployed"
  value       = local.subnet_id
}


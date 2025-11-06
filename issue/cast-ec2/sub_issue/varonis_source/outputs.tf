output "instance_id" {
  description = "ID of the Varonis EC2 instance"
  value       = aws_instance.varonis.id
}

output "private_ip" {
  description = "Private IP address of the Varonis instance"
  value       = aws_instance.varonis.private_ip
}

output "ssh_key_secret_arn" {
  description = "ARN of the SSH private key stored in Secrets Manager"
  value       = aws_secretsmanager_secret.ssh_private_key.arn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.varonis_sg.id
}

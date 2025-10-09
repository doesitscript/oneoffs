locals {
  account_id = "925774240130"
  profile    = "CASTSoftware_dev_925774240130_admin"
  region     = "us-east-2"

  cast_allowed_ips = [
    "0.0.0.0/0" # TODO: Replace with actual CAST office IPs
  ]
}

# Get the CAST Software Dev VPC for the security group
data "aws_vpc" "cast_vpc" {
  filter {
    name   = "tag:Name"
    values = ["castsoftwaredev"]
  }
}

# Security group for CAST EC2 instance
resource "aws_security_group" "cast_ec2_sg" {
  name_prefix = "cast-ec2-sg-"
  description = "Security group for CAST EC2 instance - allows SSH, RDP, HTTP, and HTTPS access"
  vpc_id      = data.aws_vpc.cast_vpc.id

  # SSH access from CAST allowed IPs
  ingress {
    description = "SSH access from CAST offices"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.cast_allowed_ips
  }

  # RDP access from CAST allowed IPs
  ingress {
    description = "RDP access from CAST offices"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = local.cast_allowed_ips
  }

  # HTTP access from anywhere
  ingress {
    description = "HTTP access from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Only create ingress rules if allowed IPs are provided
  # dynamic "ingress" {
  #   for_each = length(var.cast_allowed_ips) > 0 ? var.cast_allowed_ips : []
  #   content {
  # HTTPS access from anywhere
  ingress {
    description = "HTTPS access from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cast-ec2-security-group"
    Project     = "CAST-EC2"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# debug: sanity check get current caller 
data "aws_caller_identity" "current" {}

# debug: show account and profile used working
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

# debug: show account and profile used working
output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

# Security group output
output "security_group_id" {
  description = "ID of the CAST EC2 security group"
  value       = aws_security_group.cast_ec2_sg.id
}

output "security_group_arn" {
  description = "ARN of the CAST EC2 security group"
  value       = aws_security_group.cast_ec2_sg.arn
}

# TODO: document The r5a.24xlarge instance is in the Memory optimized family with 96 vCPUs, 768 GiB of memory and 20 Gibps of bandwidth starting at $5.424 per hour.
resource "aws_instance" "example" {
  ami           = "ami-0684b1bd72f4b0d55" # Amazon Linux 2 AMI (us-east-1)
  instance_type = "r5a.24xlarge"

  tags = {
    Name = "cast-software-dev-example"
  }
}

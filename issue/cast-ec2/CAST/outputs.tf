
output "account_id" {
  description = "AWS Account ID where resources are deployed"
  value       = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  description = "ARN of the AWS identity used for deployment"
  value       = data.aws_caller_identity.current.arn
}

output "region" {
  description = "AWS region where resources are deployed"
  value       = local.region
}

# VPC Information
output "vpc_id" {
  description = "ID of the VPC where CAST EC2 instance is deployed"
  value       = data.aws_vpc.cast_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the CAST VPC"
  value       = data.aws_vpc.cast_vpc.cidr_block
}

output "vpc_name" {
  description = "Name tag of the CAST VPC"
  value       = data.aws_vpc.cast_vpc.tags.Name
}

# =============================================================================
# EC2 INSTANCE OUTPUTS
# =============================================================================

output "instance_id" {
  description = "ID of the CAST EC2 instance"
  value       = aws_instance.example.id
}

output "instance_arn" {
  description = "ARN of the CAST EC2 instance"
  value       = aws_instance.example.arn
}

output "instance_public_ip" {
  description = "Public IP address of the CAST EC2 instance (if applicable)"
  value       = aws_instance.example.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the CAST EC2 instance"
  value       = aws_instance.example.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the CAST EC2 instance (if applicable)"
  value       = aws_instance.example.public_dns
}

output "instance_private_dns" {
  description = "Private DNS name of the CAST EC2 instance"
  value       = aws_instance.example.private_dns
}

output "instance_state" {
  description = "Current state of the CAST EC2 instance"
  value       = aws_instance.example.instance_state
}

output "instance_type" {
  description = "Instance type of the CAST EC2 instance"
  value       = aws_instance.example.instance_type
}

output "instance_ami" {
  description = "AMI ID used for the CAST EC2 instance"
  value       = aws_instance.example.ami
}

output "instance_availability_zone" {
  description = "Availability zone where the CAST EC2 instance is deployed"
  value       = aws_instance.example.availability_zone
}

output "instance_subnet_id" {
  description = "Subnet ID where the CAST EC2 instance is deployed"
  value       = aws_instance.example.subnet_id
}

output "subnet_cidr_block" {
  description = "CIDR block of the subnet where the CAST EC2 instance is deployed"
  value       = data.aws_subnet.cast_vpc_default_subnet.cidr_block
}

output "subnet_availability_zone" {
  description = "Availability zone of the subnet where the CAST EC2 instance is deployed"
  value       = data.aws_subnet.cast_vpc_default_subnet.availability_zone
}

# =============================================================================
# SECURITY GROUP OUTPUTS
# =============================================================================

output "security_group_id" {
  description = "ID of the security group attached to the CAST EC2 instance"
  value       = aws_security_group.cast_ec2_sg.id
}

output "security_group_arn" {
  description = "ARN of the security group attached to the CAST EC2 instance"
  value       = aws_security_group.cast_ec2_sg.arn
}

output "security_group_name" {
  description = "Name of the security group attached to the CAST EC2 instance"
  value       = aws_security_group.cast_ec2_sg.name
}

# =============================================================================
# EBS VOLUME OUTPUTS
# =============================================================================

output "root_volume_info" {
  description = "Information about the root EBS volume"
  value = {
    volume_id   = aws_instance.example.root_block_device[0].volume_id
    volume_type = aws_instance.example.root_block_device[0].volume_type
    volume_size = aws_instance.example.root_block_device[0].volume_size
    iops        = aws_instance.example.root_block_device[0].iops
    throughput  = aws_instance.example.root_block_device[0].throughput
    encrypted   = aws_instance.example.root_block_device[0].encrypted
  }
}

output "data_volume_info" {
  description = "Information about the additional data EBS volume"
  value = [
    for device in aws_instance.example.ebs_block_device : {
      volume_id   = device.volume_id
      device_name = device.device_name
      volume_type = device.volume_type
      volume_size = device.volume_size
      iops        = device.iops
      throughput  = device.throughput
      encrypted   = device.encrypted
    }
  ]
}

# =============================================================================
# CONNECTIVITY AND ACCESS OUTPUTS
# =============================================================================

output "rdp_connection_info" {
  description = "RDP connection information for the CAST EC2 instance"
  value = {
    public_ip          = aws_instance.example.public_ip
    private_ip         = aws_instance.example.private_ip
    port               = 3389
    username           = "Administrator" # Default Windows Administrator
    connection_command = aws_instance.example.public_ip != "" ? "mstsc /v:${aws_instance.example.public_ip}" : "Use SSM Session Manager or VPN to access ${aws_instance.example.private_ip}"
  }
}

output "ssh_connection_info" {
  description = "SSH connection information (if applicable)"
  value = {
    public_ip          = aws_instance.example.public_ip
    private_ip         = aws_instance.example.private_ip
    port               = 22
    connection_command = aws_instance.example.public_ip != "" ? "ssh -i <key-file> ec2-user@${aws_instance.example.public_ip}" : "Use SSM Session Manager to access ${aws_instance.example.private_ip}"
  }
}

# =============================================================================
# MONITORING AND MANAGEMENT OUTPUTS
# =============================================================================

output "cloudwatch_log_group" {
  description = "CloudWatch log group for CAST EC2 instance (if configured)"
  value       = "cast-ec2-${aws_instance.example.id}"
}

output "ssm_session_manager_command" {
  description = "AWS CLI command to start SSM Session Manager session"
  value       = "aws ssm start-session --target ${aws_instance.example.id} --region ${local.region}"
}

# =============================================================================
# COST AND BILLING OUTPUTS
# =============================================================================

output "estimated_hourly_cost" {
  description = "Estimated hourly cost for the CAST EC2 instance"
  value = {
    instance_type           = aws_instance.example.instance_type
    estimated_cost_per_hour = "$5.424" # r5a.24xlarge pricing as of documentation
    note                    = "Cost may vary based on region and current AWS pricing"
  }
}

# =============================================================================
# VALIDATION AND TESTING OUTPUTS
# =============================================================================

output "connectivity_test_commands" {
  description = "Commands to test connectivity to the CAST EC2 instance"
  value = {
    ping_test = "ping ${aws_instance.example.public_ip != "" ? aws_instance.example.public_ip : aws_instance.example.private_ip}"
    rdp_test  = "telnet ${aws_instance.example.public_ip != "" ? aws_instance.example.public_ip : aws_instance.example.private_ip} 3389"
    ssh_test  = "telnet ${aws_instance.example.public_ip != "" ? aws_instance.example.public_ip : aws_instance.example.private_ip} 22"
  }
}

output "current_allowed_ips" {
  description = "Current IP addresses allowed to access the CAST EC2 instance"
  value = {
    allowed_cidr_blocks = var.allowed_cidr_blocks
    note                = "If no specific IPs were provided, this shows your current public IP"
  }
}

output "deployment_summary" {
  description = "Summary of the CAST EC2 deployment"
  value = {
    project_name         = "CAST-EC2"
    environment          = local.env
    account_id           = data.aws_caller_identity.current.account_id
    region               = local.region
    vpc_id               = data.aws_vpc.cast_vpc.id
    instance_id          = aws_instance.example.id
    instance_type        = aws_instance.example.instance_type
    security_group_id    = aws_security_group.cast_ec2_sg.id
    deployment_timestamp = timestamp()
  }
}

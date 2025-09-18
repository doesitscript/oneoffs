locals {
  account_id   = "925774240130"
  profile      = "CASTSoftware_dev_925774240130_admin"
  region       = "us-east-2"
  region_short = "u2e"
  app          = "castsoftware"
  env          = "dev"

  # Tags
  common_tags = {
    Project     = local.app
    Environment = local.env
    ManagedBy   = "Terraform"
    Owner       = "CAST Team"
  }
}

# debug: sanity check get current caller 
data "aws_caller_identity" "current" {}

# grabbing default vpc for the account
data "aws_vpc" "cast_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${local.app}${local.env}"]
  }
}

# Get the first available subnet in the VPC
data "aws_subnet" "cast_vpc_default_subnet" {
  vpc_id = data.aws_vpc.cast_vpc.id

  filter {
    name   = "availability-zone"
    values = ["${local.region}a"] # Use first AZ in the region
  }
}

# TODO Document On-Prem to VPC traffic
# On-Prem (10.60.0.0/14, 10.160.0.0/14)
#    <->
# Direct Connect Gateway (DXGW)
#    <->
# Transit Gateway (tgw-070334cf083fca7cc)
#    <->
# Transit Gateway Route Table (tgw-rtb-00cb37f6985c2442e)
#    <->
# Attached VPCs (e.g., your CAST VPC 10.62.20.0/24)
resource "aws_security_group" "cast_ec2_sg" {
  name_prefix = "cast-ec2-sg-"
  description = "Security group for CAST EC2 instance - allows SSH, RDP, HTTP, and HTTPS access"
  vpc_id      = data.aws_vpc.cast_vpc.id
  ingress = [
    {
      description = "SSH access from CAST allowed IPs"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    },
    {
      description = "RDP access from CAST allowed IPs"
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  ]
  # ingress = [

  #   {
  #     description = "SSH access from CAST allowed IPs"
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = "tcp"
  #     cidr_blocks = var.allowed_cidr_blocks
  #   },
  #   {
  #     description = "RDP access from CAST allowed IPs"
  #     from_port   = 3389
  #     to_port     = 3389
  #     protocol    = "tcp"
  #     cidr_blocks = var.allowed_cidr_blocks
  #   }
  # ]
}

# TODO: document The r5a.24xlarge instance is in the Memory optimized family with 96 vCPUs, 768 GiB of memory and 20 Gibps of bandwidth starting at $5.424 per hour.
resource "aws_instance" "example" {
  ami                    = "ami-0684b1bd72f4b0d55" # Amazon Linux 2 AMI (us-east-1)
  instance_type          = "r5a.24xlarge"
  vpc_security_group_ids = [aws_security_group.cast_ec2_sg.id]
  subnet_id              = data.aws_subnet.cast_vpc_default_subnet.id

  # Enable EBS optimization for better performance
  ebs_optimized = true

  # Root volume configuration
  root_block_device {
    volume_type = "gp3"
    volume_size = 100
    iops        = 3000
    throughput  = 125
    encrypted   = true

    tags = {
      Name = "cast-ec2-root-volume"
    }
  }

  # Additional data volume
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp3"
    volume_size = 500
    iops        = 4000
    throughput  = 250
    encrypted   = true

    tags = {
      Name = "cast-ec2-data-volume"
    }
  }

  tags = {
    Name        = "cast-software-dev-example"
    Project     = "CAST-EC2"
    Environment = "Development"
    ManagedBy   = "Terraform"
    Owner       = "CAST Software"
  }
}

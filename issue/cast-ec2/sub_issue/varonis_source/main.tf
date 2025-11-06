locals {
  name_prefix = "varonis"
}

# Generate SSH Key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Store SSH Key in Secrets Manager
resource "aws_secretsmanager_secret" "ssh_private_key" {
  name                    = "${local.name_prefix}-ssh-key-Production"
  description             = "SSH private key for ${local.name_prefix} instance"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-ssh-key"
  })
}

resource "aws_secretsmanager_secret_version" "ssh_private_key" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key.id
  secret_string = tls_private_key.ssh_key.private_key_openssh
}

# Create Key Pair
resource "aws_key_pair" "varonis_key" {
  key_name   = "${local.name_prefix}-key-Production"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-key"
  })
}

# Security Group
resource "aws_security_group" "varonis_sg" {
  name        = "${local.name_prefix}-sg-Production"
  description = "Security Group for ${local.name_prefix} instance"
  vpc_id      = data.aws_ssm_parameter.vpc_id.insecure_value

  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-sg"
  })
}

# Find latest Windows AMI with name starting with "amidistribution"
data "aws_ami" "windows_ami" {
  most_recent = true
  owners      = ["422228628991"]  # customer-image-mgmt account

  filter {
    name   = "name"
    values = ["amidistribution*"]
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

# EC2 Instance
resource "aws_instance" "varonis" {
  ami                  = data.aws_ami.windows_ami.id
  instance_type        = "m5.8xlarge" # 32 vCPUs, 128 GB RAM (closest to 64GB requirement)
  iam_instance_profile = aws_iam_instance_profile.varonis_profile.name
  key_name             = aws_key_pair.varonis_key.key_name
  subnet_id            = local.subnet_id
  vpc_security_group_ids = [aws_security_group.varonis_sg.id]

  metadata_options {
    http_tokens = "required"
  }

  disable_api_termination = true

  user_data = "brd03w255,prod"

  # C: Drive (250 GB)
  root_block_device {
    volume_size           = 250
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

    tags = merge(var.tags, {
      Name = "${local.name_prefix}-c-drive"
    })
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-instance"
  })

  lifecycle {
    ignore_changes = [ami]
  }
}

# D: Drive (500 GB)
resource "aws_ebs_volume" "d_drive" {
  availability_zone = aws_instance.varonis.availability_zone
  size              = 500
  type              = "gp3"
  encrypted         = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-d-drive"
  })
}

resource "aws_volume_attachment" "d_drive" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.d_drive.id
  instance_id = aws_instance.varonis.id
}

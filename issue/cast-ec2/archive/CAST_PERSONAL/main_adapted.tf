# Generate SSH Key for Windows RDP (optional, but good practice)
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Store SSH Key in Secrets Manager
resource "aws_secretsmanager_secret" "ssh_private_key" {
  name                    = "${var.project_name}-${var.environment}-ssh-key"
  description             = "SSH private key for ${var.project_name} instance"
  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-ssh-key"
  })
}

resource "aws_secretsmanager_secret_version" "ssh_private_key" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key.id
  secret_string = tls_private_key.ssh_key.private_key_openssh
}

# Create Key Pair
resource "aws_key_pair" "cast_key" {
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-key"
  })
}

# Security Group - simplified version of your existing approach
resource "aws_security_group" "cast_sg" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security Group for ${var.project_name} instance"
  vpc_id      = data.aws_vpc.default_vpc.id

  # RDP access from allowed CIDR blocks
  dynamic "ingress" {
    for_each = local.all_allowed_cidr_blocks
    content {
      description = "RDP from ${ingress.value}"
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # HTTPS access from allowed CIDR blocks
  dynamic "ingress" {
    for_each = local.all_allowed_cidr_blocks
    content {
      description = "HTTPS from ${ingress.value}"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-sg"
  })
}

# EC2 Instance - adapted from Varonis but using your configuration
resource "aws_instance" "cast" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.cast_profile.name
  key_name               = aws_key_pair.cast_key.key_name
  subnet_id              = local.subnet_id
  vpc_security_group_ids = [aws_security_group.cast_sg.id]

  associate_public_ip_address = var.enable_public_ip
  ebs_optimized               = var.enable_ebs_optimization

  metadata_options {
    http_tokens = "required"
  }

  disable_api_termination = true

  # Use your user_data if you have specific requirements
  # user_data = "your-custom-user-data-here"

  # C: Drive (Root Volume)
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    iops                  = var.root_volume_iops
    throughput            = var.root_volume_throughput
    encrypted             = var.enable_encryption
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = "${var.project_name}-${var.environment}-c-drive"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-instance"
  })

  lifecycle {
    ignore_changes = [ami]
  }
}

# D: Drive (Data Volume) - using your existing approach
resource "aws_ebs_volume" "d_drive" {
  availability_zone = aws_instance.cast.availability_zone
  size              = var.data_volume_size
  type              = var.data_volume_type
  iops              = var.data_volume_iops
  throughput        = var.data_volume_throughput
  encrypted         = var.enable_encryption

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-d-drive"
  })
}

resource "aws_volume_attachment" "d_drive" {
  device_name = var.data_volume_device_name
  volume_id   = aws_ebs_volume.d_drive.id
  instance_id = aws_instance.cast.id
}


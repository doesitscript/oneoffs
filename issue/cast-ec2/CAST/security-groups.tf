# Base corporate network traffic
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

  # Allowing all internet traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "cast-ec2-base-security-group"
    Type = "Base"
  })
}

# Security group for expectd/standar access apps
resource "aws_security_group" "default" {
  name_prefix = "cast-ec2-sg-default"
  description = "Standard per app excepts base security group"
  vpc_id      = data.aws_vpc.default_vpc.id

  # SSH access
  ingress {
    description = "SSH access from CAST allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.all_allowed_cidr_blocks
  }

  # RDP access
  ingress {
    description = "RDP access from CAST allowed IPs"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = local.all_allowed_cidr_blocks
  }

  # Allowing all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "cast-ec2-default-security-group"
    Type = "Default"
  })
}

# AFT compatibility security group for accounts with firewall routing
resource "aws_security_group" "aft_default_customization_compatibility" {
  name_prefix = "cast-ec2-sg-aft-default-customization-compatibility"
  description = "Security group for vpcs that have default configuration directing traffic to firewall by default."
  vpc_id      = data.aws_vpc.default_vpc.id

  # egress rules for allowed CIDR blocks
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

  #  ingress rules for allowed CIDR blocks
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

  tags = merge(local.common_tags, {
    Name = "cast-ec2-aft-compatibility-security-group"
    Type = "AFT-Compatibility"
  })
}

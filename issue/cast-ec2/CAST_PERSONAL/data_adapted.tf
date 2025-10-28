data "aws_region" "current" {}

# Get current AWS caller identity for debugging and outputs
data "aws_caller_identity" "current" {}

# CAST VPC - using your existing approach
data "aws_vpc" "default_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.app}${var.env}"]
  }
}

# All subnets in the VPC
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

# Get the first subnet (your current approach)
data "aws_subnet" "selected_subnet" {
  id = data.aws_subnets.default_vpc_subnets.ids[0]
}

locals {
  # Use the first subnet from your VPC
  subnet_id = data.aws_subnets.default_vpc_subnets.ids[0]
}

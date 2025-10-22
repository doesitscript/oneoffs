# Get current AWS caller identity for debugging and outputs
data "aws_caller_identity" "current" {}

# CAST VPC
data "aws_vpc" "default_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${local.app}${local.env}"]
  }
}

# All subnets in the VPC. "Default" == the first subnet in the list
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

# SInce no default is set, using first subnet in the list
data "aws_subnet" "selected_subnet" {
  id = local.default_vpc_subnet_id
}

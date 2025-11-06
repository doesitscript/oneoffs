data "aws_region" "current" {}

data "aws_ssm_parameter" "vpc_id" {
  name = "/platform/vpc/varonis-prd/vpc-id"
}

data "aws_ssm_parameter" "subnet_ids" {
  name = "/platform/vpc/varonis-prd/subnet-ids"
}

locals {
  subnet_data = jsondecode(data.aws_ssm_parameter.subnet_ids.insecure_value)
  # Get the first non-tgw subnet type for us-east-2a
  non_tgw_types = [for k, v in local.subnet_data : k if k != "tgw"]
  subnet_id     = local.subnet_data[local.non_tgw_types[0]]["us-east-2a"]
}
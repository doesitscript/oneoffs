data "aws_region" "current" {}

data "aws_ssm_parameter" "vpc_id" {
  name = "/platform/vpc/castsoftwaredev/vpc-id"
}

data "aws_ssm_parameter" "cast_subnets" {
  name = "/platform/vpc/castsoftwaredev/subnet-ids"
}

locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value #note, both tgw and castsoftwaredev vpc-id

  subnets_json = jsondecode(data.aws_ssm_parameter.cast_subnets.insecure_value)

  cast_map = try(local.subnets_json["castsoftwaredev"], {})
  # tgw_map = try(local.subnets_json["tgw"], {})

  # castsoftwaredev["us-east-2b"] => subnet-0d347343d225727ce

  cast_subnet_ids_all = [for k, v in local.cast_map : v]

  # check azs to handle empty ssm, no subnets in ssm, vpc no vend, 
  az_order = ["us-east-2a", "us-east-2b", "us-east-2c"]

  cast_subnet_id_available = [
    for az in local.az_order : lookup(local.cast_map, az, null)
    if lookup(local.cast_map, az, null) != null
  ]

  cast_subnet_id_available_count = length(local.cast_subnet_id_available)

  cast_subnet_id_available_count_check = local.cast_subnet_id_available_count > 0

  cast_subnet_id_available_count_check_message = "No subnets available in SSM"

  # cast_subnet_ids_2 = slice(local.cast_subnet_id_available, 0, 1) # will ask CAST, currently only one subnet
  cast_subnet_ids_1 = local.cast_subnet_id_available[0]
}

# export AWS_PROFILE=CASTSoftware_dev_925774240130_admin
# terraform console <<EOF
# data.aws_ssm_parameter.subnet_ids.value
# data.aws_ssm_parameter.subnet_ids.insecure_value
# EOF there

# AWS_PROFILE=CASTSoftware_dev_925774240130_admin && terraform console <<EOF 2>&1
# data.aws_ssm_parameter.subnet_ids.insecure_value
# EOF
# "{\"castsoftwaredev\":{\"us-east-2a\":\"subnet-0900c846fdabad701\",\"us-east-2b\":\"subnet-0d347343d225727ce\",\"us-east-2c\":\"subnet-07bf214b154b462aa\"},\"tgw\":{\"us-east-2a\":\"subnet-056ff6ed1d149cbc3\",\"us-east-2b\":\"subnet-04fb74ad031d75942\",\"us-east-2c\":\"subnet-017c107f70413bbb9\"}}"                                                                                 

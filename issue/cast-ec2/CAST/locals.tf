# =============================================================================
# LOCAL VALUES AND COMMON TAGS
# =============================================================================

locals {
  # Use variables instead of hardcoded values
  account_id   = var.account_id
  profile      = var.profile
  region       = var.region
  region_short = var.region_short
  app          = var.app
  env          = var.env

  # Tags
  common_tags = merge(
    {
      Project     = local.app
      Environment = local.env
      ManagedBy   = "Terraform"
      Owner       = "CAST Team"
    },
    var.tags
  )

  # There's an open issue on aft-account-request track what we need to implement in aws (ie set default subnet at account vending )
  # or we could select subnet by az
  default_vpc_subnet_id   = data.aws_subnets.default_vpc_subnets.ids[0]
  all_allowed_cidr_blocks = concat(var.aft_allowed_cidr_blocks, var.allowed_cidr_blocks)
}

Task: Create locals.tf and normalize naming/tags across resources.

Steps:
1) Create locals.tf with:
   - variable "environment" (dev|qa|prod)
   - variable "app_name" (cast)
   - variable "tags" (map(string), default {})
   - locals:
       name_prefix = "${var.app_name}-${var.environment}"
       common_tags = merge(var.tags, {
         Application = var.app_name
         Environment = var.environment
         ManagedBy   = "Terraform"
       })

2) In every resource file, replace ad-hoc tag blocks with:
   tags = local.common_tags

3) Replace hardcoded names like "...-Production" with:
   name = "${local.name_prefix}-<purpose>"

4) Run: terraform fmt -recursive

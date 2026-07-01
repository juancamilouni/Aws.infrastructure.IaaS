include {
  path = find_in_parent_folders("terragrunt_aws.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

terraform {
  source = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Arre-IaC//kms?ref=modulos-v0.0.2"
}

inputs = {
  description = "KMS key for ${local.common_vars.project_name}-${local.common_vars.environment} WordPress infrastructure"

  aliases = [
    "wordpress/${local.common_vars.project_name}-${local.common_vars.environment}"
  ]

  enable_default_policy = true

  key_owners         = []
  key_administrators = []
  key_users          = []
  key_service_users  = []

  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = false

  key_statements = []

  tags = local.common_vars.tags
}
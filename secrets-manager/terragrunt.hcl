include {
  path = find_in_parent_folders("terragrunt_aws.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

terraform {
  source = "git::https://github.com/juancamilouni/Aws.Modules.infrastructure.git//secrets-manager?ref=main"
}

inputs = {
  name        = "${local.common_vars.project_name}/${local.common_vars.environment}/database"
  description = "Credenciales de base de datos Magento DEV."

  secret_values = {
    username = local.common_vars.rds.username
    dbname   = local.common_vars.rds.database_name
  }

  generate_password = true
  password_key      = "password"
  tags              = local.common_vars.tags
}

include {
  path = find_in_parent_folders("terragrunt_aws.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "git::https://github.com/juancamilouni/Aws.Modules.infrastructure.git//security-groups-magento?ref=main"
}

inputs = {
  name_prefix         = "${local.common_vars.project_name}-${local.common_vars.environment}"
  vpc_id              = dependency.vpc.outputs.vpc_id
  allowed_https_cidrs = local.common_vars.security.allowed_admin_cidrs
  enable_http         = true
  magento_http_port   = 80
  database_port       = 3306
  opensearch_port     = 443
  redis_port          = 6379
  tags                = local.common_vars.tags
}

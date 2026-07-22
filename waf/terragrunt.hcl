include {
  path = find_in_parent_folders("terragrunt_aws.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

dependency "alb" {
  config_path = "../alb"
}

terraform {
  source = "git::https://github.com/juancamilouni/Aws.Modules.infrastructure.git//waf?ref=main"
}

inputs = {
  name               = "waf-${local.common_vars.project_name}-${local.common_vars.environment}"
  scope              = "REGIONAL"
  allowed_ipv4_cidrs = local.common_vars.security.allowed_admin_cidrs
  alb_arn            = dependency.alb.outputs.arn
  associate_alb      = true
  tags               = local.common_vars.tags
}

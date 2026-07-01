include {
  path = find_in_parent_folders("terragrunt_aws.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

dependency "vpc" {
  config_path  = "../vpc"
  skip_outputs = false
}

terraform {
  source = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Arre-IaC//security-groups?ref=modulos-v0.0.2"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  alb_security_group_name         = "albsg-${local.common_vars.project_name}-${local.common_vars.environment}"
  wordpress_security_group_name   = "wpsg-${local.common_vars.project_name}-${local.common_vars.environment}"
  rds_security_group_name         = "rdssg-${local.common_vars.project_name}-${local.common_vars.environment}"
  efs_security_group_name         = "efssg-${local.common_vars.project_name}-${local.common_vars.environment}"
  elasticache_security_group_name = "cachesg-${local.common_vars.project_name}-${local.common_vars.environment}"

  enable_http  = true
  allowed_http_cidr = "0.0.0.0/0"

  # Producción: solo CloudFront entra por HTTPS
  restrict_alb_to_cloudfront = true

  # Solo usado si restrict_alb_to_cloudfront = false
  allowed_https_cidr = "0.0.0.0/0"

  wordpress_http_port = 80
  database_port       = 3306
  elasticache_port    = 11211

  tags = local.common_vars.tags
}
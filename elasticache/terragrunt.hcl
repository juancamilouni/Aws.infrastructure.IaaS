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

dependency "security_groups" {
  config_path  = "../security-groups"
  skip_outputs = false
}

terraform {
  source = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Arre-IaC//elasticache?ref=modulos-v0.0.8"
}

inputs = {
  cluster_id = "memcached-${local.common_vars.project_name}-${local.common_vars.environment}"

  engine_version = "1.6.17"
  node_type      = "cache.t4g.micro"

  num_cache_nodes = 1
  az_mode         = "single-az"

  maintenance_window = "sun:05:00-sun:09:00"
  apply_immediately  = true

  security_group_ids = [
    dependency.security_groups.outputs.elasticache_security_group_id
  ]

  subnet_ids = dependency.vpc.outputs.database_subnet_ids

  create_parameter_group = true
  parameter_group_family = "memcached1.6"

  parameters = [
    {
      name  = "idle_timeout"
      value = "60"
    }
  ]

  tags = local.common_vars.tags
}
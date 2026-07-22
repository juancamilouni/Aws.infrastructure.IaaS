include {
  path = find_in_parent_folders("terragrunt_aws.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_groups" {
  config_path = "../security-groups-magento"
}

terraform {
  source = "git::https://github.com/juancamilouni/Aws.Modules.infrastructure.git//opensearch?ref=main"
}

inputs = {
  domain_name        = local.common_vars.opensearch.domain_name
  engine_version     = local.common_vars.opensearch.engine_version
  vpc_id             = dependency.vpc.outputs.vpc_id
  subnet_ids         = dependency.vpc.outputs.private_subnet_ids
  security_group_ids = [dependency.security_groups.outputs.opensearch_security_group_id]

  instance_type  = local.common_vars.opensearch.instance_type
  instance_count = local.common_vars.opensearch.instance_count
  volume_size    = local.common_vars.opensearch.volume_size

  zone_awareness_enabled  = false
  encrypt_at_rest         = true
  node_to_node_encryption = true
  enforce_https           = true
  log_retention_in_days   = local.common_vars.cloudwatch.retention_in_days
  tags                    = local.common_vars.tags
}

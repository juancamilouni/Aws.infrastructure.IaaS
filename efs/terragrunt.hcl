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

dependency "kms" {
  config_path  = "../kms"
  skip_outputs = false
}

terraform {
  source = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Arre-IaC//efs?ref=modulos-v0.0.4"
}

inputs = {
  name           = "efs-${local.common_vars.project_name}-${local.common_vars.environment}"
  creation_token = "${local.common_vars.project_name}-${local.common_vars.environment}-efs"

  encrypted   = true
  kms_key_arn = dependency.kms.outputs.key_arn

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  mount_targets = {
    for idx, subnet_id in dependency.vpc.outputs.database_subnet_ids :
    idx => {
      subnet_id = subnet_id
    }
  }

  security_group_vpc_id = dependency.vpc.outputs.vpc_id

  security_group_ingress_rules = {
    wordpress = {
      description                  = "Allow NFS from WordPress instances"
      referenced_security_group_id = dependency.security_groups.outputs.wordpress_security_group_id
    }
  }

  enable_backup_policy = false

  tags = local.common_vars.tags
}
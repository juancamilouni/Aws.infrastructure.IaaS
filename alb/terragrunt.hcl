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
  source = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Arre-IaC//alb?ref=modulos-v0.0.9"
}

inputs = {
  name = "alb-${local.common_vars.project_name}-${local.common_vars.environment}"

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.public_subnet_ids

  security_group_ids = [
    dependency.security_groups.outputs.alb_security_group_id
  ]

  internal = false

  certificate_arn = local.common_vars.certificates.alb_certificate_arn

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  access_logs = null

  target_group_name_prefix = "wp-"
  target_group_port        = 80

  deregistration_delay              = 30
  load_balancing_cross_zone_enabled = true

  health_check_path     = "/"
  health_check_interval = 30
  health_check_timeout  = 5
  healthy_threshold     = 3
  unhealthy_threshold   = 3
  health_check_matcher  = "200-399"

  tags = local.common_vars.tags
}
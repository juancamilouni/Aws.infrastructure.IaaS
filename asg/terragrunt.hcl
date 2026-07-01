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

dependency "alb" {
  config_path  = "../alb"
  skip_outputs = false
}

dependency "efs" {
  config_path  = "../efs"
  skip_outputs = false
}

dependency "rds" {
  config_path  = "../rds"
  skip_outputs = false
}

dependency "security_groups" {
  config_path  = "../security-groups"
  skip_outputs = false
}

terraform {
  source = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Arre-IaC//asg?ref=modulos-v0.0.9"
}

inputs = {
  name          = "asg-${local.common_vars.project_name}-${local.common_vars.environment}"
  instance_name = "ec2-${local.common_vars.project_name}-${local.common_vars.environment}"

  ami_id        = null
  instance_type = "t3.micro"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  subnet_ids = dependency.vpc.outputs.private_subnet_ids

  security_group_ids = [
    dependency.security_groups.outputs.wordpress_security_group_id
  ]

  target_group_arns = [
    dependency.alb.outputs.wordpress_target_group_arn
  ]

  efs_dns         = dependency.efs.outputs.dns_name
  efs_mount_point = "/mnt/efs"

  secrets_manager_secret_arns = [
    dependency.rds.outputs.cluster_master_user_secret[0].secret_arn
  ]

  additional_policy_arns = []

  enable_detailed_monitoring = true

  root_device_name       = "/dev/xvda"
  root_volume_size       = 20
  root_volume_type       = "gp3"
  root_volume_encrypted  = true
  root_volume_kms_key_id = null

  health_check_grace_period = 300
  protect_from_scale_in     = false

  tags = local.common_vars.tags
}
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
  source = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Arre-IaC//rds?ref=modulos-v0.0.7"
}

inputs = {
  name = "rds-${local.common_vars.project_name}-${local.common_vars.environment}"

  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.08.0"
  engine_mode    = "provisioned"

  database_name   = "wordpress_db"
  master_username = "wordpress_admin"

  manage_master_user_password = true

  instance_class = "db.t4g.medium"

  instances = {
    1 = {}
  }

  vpc_id               = dependency.vpc.outputs.vpc_id
  db_subnet_group_name = dependency.vpc.outputs.database_subnet_group_name

  vpc_security_group_ids = [
    dependency.security_groups.outputs.rds_security_group_id
  ]

  storage_encrypted = true
  kms_key_id        = dependency.kms.outputs.key_arn

  apply_immediately   = true
  skip_final_snapshot = true
  deletion_protection = false

  backup_retention_period      = 15
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  delete_automated_backups     = false

  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery"
  ]

  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 30

  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = "pg-cluster-${local.common_vars.project_name}-${local.common_vars.environment}"
  db_cluster_parameter_group_family      = "aurora-mysql8.0"
  db_cluster_parameter_group_description = "Cluster parameter group for ${local.common_vars.project_name}-${local.common_vars.environment}"

  db_cluster_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = "120"
      apply_method = "immediate"
    }
  ]

  create_db_parameter_group      = true
  db_parameter_group_name        = "pg-${local.common_vars.project_name}-${local.common_vars.environment}"
  db_parameter_group_family      = "aurora-mysql8.0"
  db_parameter_group_description = "DB parameter group for ${local.common_vars.project_name}-${local.common_vars.environment}"

  db_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = "60"
      apply_method = "immediate"
    }
  ]

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval = 0

  cluster_timeouts = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  tags = local.common_vars.tags
}
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
  config_path  = "../security-groups-magento"
  skip_outputs = false
}

dependency "secrets" {
  config_path  = "../secrets-manager"
  skip_outputs = false
}

dependency "s3" {
  config_path  = "../s3"
  skip_outputs = false
}

dependency "alb" {
  config_path  = "../alb"
  skip_outputs = false
}

terraform {
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/Ibarra-magento-aws-modules//ec2-magento?ref=ec2-magento-v0.0.2"
}

inputs = {
  name          = local.common_vars.compute.name
  ami_id        = local.common_vars.compute.ami_id
  instance_type = local.common_vars.compute.instance_type

  subnet_ids = dependency.vpc.outputs.private_subnet_ids

  security_group_ids = [
    dependency.security_groups.outputs.magento_security_group_id
  ]

  target_group_arns = [
    dependency.alb.outputs.target_group_arn
  ]

  target_group_port = 80

  desired_capacity = local.common_vars.compute.desired_capacity
  min_size         = local.common_vars.compute.min_size
  max_size         = local.common_vars.compute.max_size

  root_volume_size = local.common_vars.compute.root_volume_size
  root_volume_type = local.common_vars.compute.root_volume_type

  associate_public_ip_address = false

  application_log_group_name = local.common_vars.cloudwatch.application_log_group_name
  log_retention_in_days      = local.common_vars.cloudwatch.retention_in_days

  secret_arns = [
    dependency.secrets.outputs.secret_arn
  ]

  s3_bucket_arns = [
    dependency.s3.outputs.bucket_arn
  ]

  opensearch_domain_arns = [
    dependency.opensearch.outputs.domain_arn
  ]

  user_data_extra = <<-EOT
    if command -v dnf >/dev/null 2>&1; then
      dnf install -y docker
      systemctl enable --now docker
      usermod -aG docker ec2-user || true
    fi

    if command -v yum >/dev/null 2>&1; then
      yum install -y docker
      systemctl enable --now docker
      usermod -aG docker ec2-user || true
    fi

    echo "Magento DEV standalone instance ready" > /var/www/html/index.html
  EOT

  tags = local.common_vars.tags
}
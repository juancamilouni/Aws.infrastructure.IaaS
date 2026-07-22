include {
  path = find_in_parent_folders("terragrunt_aws.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

dependency "ec2_magento" {
  config_path = "../ec2-magento"
}

terraform {
  source = "git::https://github.com/juancamilouni/Aws.Modules.infrastructure.git//cicd?ref=main"
}

inputs = {
  name                    = local.common_vars.cicd.name
  artifact_bucket_name    = local.common_vars.cicd.artifact_bucket_name
  codestar_connection_arn = local.common_vars.cicd.codestar_connection_arn
  repository_id           = local.common_vars.cicd.repository_id
  branch_name             = local.common_vars.cicd.branch_name

  asg_name             = dependency.ec2_magento.outputs.autoscaling_group_name
  codedeploy_tag_key   = "CodeDeploy"
  codedeploy_tag_value = local.common_vars.compute.name

  tags = local.common_vars.tags
}

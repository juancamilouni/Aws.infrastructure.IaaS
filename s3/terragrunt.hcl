include {
  path = find_in_parent_folders("terragrunt_aws.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

dependency "kms" {
  config_path  = "../kms"
  skip_outputs = false
}

terraform {
  source = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Arre-IaC//s3?ref=modulos-v0.0.2"
}

inputs = {
  bucket_name = "s3-${local.common_vars.project_name}-${local.common_vars.environment}-assets"

  force_destroy     = false
  enable_versioning = true

  kms_key_arn = dependency.kms.outputs.key_arn

  object_ownership = "BucketOwnerEnforced"

  tags = local.common_vars.tags
}
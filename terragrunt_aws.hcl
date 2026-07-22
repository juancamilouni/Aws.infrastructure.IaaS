locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket       = "ibarra-magento-terraform-state-${local.common_vars.environment}"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = local.common_vars.aws_region
    encrypt      = true
    use_lockfile = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"

  contents = <<EOF_PROVIDER
provider "aws" {
  region = "${local.common_vars.aws_region}"

  default_tags {
    tags = ${jsonencode(local.common_vars.tags)}
  }
}
EOF_PROVIDER
}

include {
  path = find_in_parent_folders("terragrunt_aws.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))

  record_name = replace(
    local.common_vars.domain,
    ".${local.common_vars.hosted_zone_name}",
    ""
  )
}

dependency "cloudfront" {
  config_path  = "../cloudfront"
  skip_outputs = false
}

terraform {
  source = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Arre-IaC//route53?ref=modulos-v0.0.10"
}

inputs = {
  zone_name    = local.common_vars.hosted_zone_name
  private_zone = false

  records = [
    {
      name                   = local.record_name
      type                   = "A"
      alias_name             = dependency.cloudfront.outputs.distribution_domain_name
      alias_zone_id          = dependency.cloudfront.outputs.distribution_hosted_zone_id
      evaluate_target_health = false
    }
  ]
}
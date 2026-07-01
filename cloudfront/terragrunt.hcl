include {
  path = find_in_parent_folders("terragrunt_aws.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

dependency "alb" {
  config_path  = "../alb"
  skip_outputs = false
}

dependency "s3_assets" {
  config_path  = "../s3"
  skip_outputs = false
}

terraform {
  source = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Arre-IaC//cloudfront?ref=modulos-v0.0.10"
}

inputs = {
  name = "cdn-${local.common_vars.project_name}-${local.common_vars.environment}"

aliases = [
  local.common_vars.domain
]

  comment = "CloudFront for ${local.common_vars.project_name}-${local.common_vars.environment}"

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"
  http_version    = "http2"

  # 🔗 ALB como origin dinámico
  alb_domain_name = dependency.alb.outputs.dns_name

  # 🔗 S3 como origin estático
  enable_s3_static_assets        = true
  s3_bucket_id                  = dependency.s3_assets.outputs.bucket_id
  s3_bucket_arn                 = dependency.s3_assets.outputs.bucket_arn
  s3_bucket_regional_domain_name = dependency.s3_assets.outputs.bucket_regional_domain_name

  # 🔐 Certificado (DEBE estar en us-east-1)
  certificate_arn = local.common_vars.certificates.cloudfront_certificate_arn

  minimum_protocol_version = "TLSv1.2_2021"

  static_asset_path_patterns = [
    "/wp-content/*",
    "/wp-includes/*"
  ]

  tags = local.common_vars.tags
}
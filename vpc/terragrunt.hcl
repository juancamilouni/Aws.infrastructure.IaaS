include {
  path = find_in_parent_folders("terragrunt_aws.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

terraform {
  source = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/Arre-IaC//vpc?ref=modulos-v0.0.2"
}

inputs = {
  vpc_name   = "vpc-${local.common_vars.project_name}-${local.common_vars.environment}"
  cidr_block = local.common_vars.networking.vpc_cidr

  availability_zones = local.common_vars.networking.availability_zones

  public_subnets   = local.common_vars.networking.public_subnets
  private_subnets  = local.common_vars.networking.private_subnets
  database_subnets = local.common_vars.networking.database_subnets

  enable_nat_gateway = local.common_vars.networking.enable_nat_gateway
  single_nat_gateway = local.common_vars.networking.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  map_public_ip_on_launch = true

  create_database_subnet_group = true

  tags = local.common_vars.tags
}
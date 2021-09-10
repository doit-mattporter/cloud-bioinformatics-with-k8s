provider "aws" {
  profile = "default"
  region  = var.aws_region
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  available_azs = data.aws_availability_zones.available.names
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.7.0"

  name            = "eks_vpc"
  cidr            = var.eks_vpc_cidr
  azs             = local.available_azs
  private_subnets = [for k, v in local.available_azs : cidrsubnet(var.eks_vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.available_azs : cidrsubnet(var.eks_vpc_cidr, 8, "${length(local.available_azs) + k}")]

  # Enabling IPv6 sometimes breaks EC2 instances' ability to join EKS. Sometimes it doesn't!
  # Either EKS or Terraform seems to struggle with full support for IPv6 so I leave it in for future use but commented out for now.
  # enable_ipv6                                    = true
  # assign_ipv6_address_on_creation                = true
  # private_subnet_assign_ipv6_address_on_creation = true
  # public_subnet_ipv6_prefixes                    = range(length(local.available_azs))
  # private_subnet_ipv6_prefixes                   = range(length(local.available_azs), "${2 * length(local.available_azs)}")

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.us-west-2.s3"
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = module.vpc.vpc_id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.us-west-2.ecr.api"
  subnet_ids          = module.vpc.private_subnets
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.allow_tls.id,
  ]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = module.vpc.vpc_id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.us-west-2.ecr.dkr"
  subnet_ids          = module.vpc.private_subnets
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.allow_tls.id,
  ]
}

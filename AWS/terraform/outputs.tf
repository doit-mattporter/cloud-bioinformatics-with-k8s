output "aws_region" {
  value = var.aws_region
}

output "eks_cluster_name" {
  value = var.eks_cluster_name
}

output "eks_vpc_cidr" {
  value = var.eks_vpc_cidr
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_private_subnets" {
  value = module.vpc.private_subnets
}

output "vpc_default_security_group_id" {
  value = module.vpc.default_security_group_id
}
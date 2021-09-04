output "aws_region" {
  description = "AWS region"
  value       = data.terraform_remote_state.vpc.outputs.aws_region
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.bioinformatics_cluster.cluster_endpoint
}

output "eks_cluster_id" {
  description = "EKS cluster ID."
  value       = module.bioinformatics_cluster.cluster_id
}

output "eks_cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = data.terraform_remote_state.vpc.outputs.eks_cluster_name
}

output "eks_cluster_ca_certificate" {
  description = "EKS cluster Certificate Authority Certificate"
  value = module.bioinformatics_cluster.cluster_certificate_authority_data
}

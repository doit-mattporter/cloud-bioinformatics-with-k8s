provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.eks_cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "kubectl" {
  load_config_file       = false
  host                   = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.eks_cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

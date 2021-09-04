data "aws_eks_cluster" "cluster" {
  name = module.bioinformatics_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.bioinformatics_cluster.cluster_id
}

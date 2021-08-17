provider "aws" {
  profile = "default"
  region  = data.terraform_remote_state.vpc.outputs.aws_region
}

module "bioinformatics_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_version
  subnets         = data.terraform_remote_state.vpc.outputs.vpc_private_subnets

  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_iam_role_name = "EKS-BioinformaticsCluster-Role"

  cluster_endpoint_private_access = true
  cluster_enabled_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups_launch_template = [
    {
      name                     = "spot_large"
      root_volume_size         = 512
      override_instance_types  = ["m5.24xlarge", "r5.24xlarge"]
      spot_allocation_strategy = "lowest-price"
      spot_instance_pools      = 2
      asg_min_size             = 1
      asg_max_size             = 20
      asg_desired_capacity     = 1
      kubelet_extra_args       = "--node-labels=node.kubernetes.io/lifecycle=spot"
    },
    {
      name                     = "spot_small"
      root_volume_size         = 512
      override_instance_types  = ["m5.xlarge", "r5.xlarge"]
      spot_allocation_strategy = "lowest-price"
      spot_instance_pools      = 2
      asg_min_size             = 1
      asg_max_size             = 20
      asg_desired_capacity     = 1
      kubelet_extra_args       = "--node-labels=node.kubernetes.io/lifecycle=spot"
    },
  ]
}

resource "aws_iam_role_policy_attachment" "s3-for-eks-bioinformatics-tasks" {
  role       = module.bioinformatics_cluster.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm-for-eks-bioinformatics-tasks" {
  role       = module.bioinformatics_cluster.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

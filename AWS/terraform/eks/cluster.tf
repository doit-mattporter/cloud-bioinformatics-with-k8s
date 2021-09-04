provider "aws" {
  profile = "default"
  region  = data.terraform_remote_state.vpc.outputs.aws_region
}

module "bioinformatics_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.10.0"

  cluster_name    = data.terraform_remote_state.vpc.outputs.eks_cluster_name
  cluster_version = var.eks_version

  cluster_endpoint_private_access = "true"

  vpc_id  = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets = data.terraform_remote_state.vpc.outputs.vpc_private_subnets

  cluster_iam_role_name = "EKS-BioinformaticsCluster-Role"

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  workers_group_defaults = {
    root_volume_size = 600
    root_volume_type = "gp2"
  }

  worker_groups_launch_template = [
    {
      name = "spot_large"
      # override_instance_types  = ["m6i.24xlarge", "m5.24xlarge"]
      override_instance_types  = ["m5.24xlarge", "r5.24xlarge"]
      spot_allocation_strategy = "lowest-price"
      spot_instance_pools      = 2
      asg_min_size             = 1
      asg_max_size             = 5
      asg_desired_capacity     = 1
      kubelet_extra_args       = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes      = ["AZRebalance"]
    },
    {
      name = "spot_small"
      # override_instance_types  = ["m6i.xlarge", "m5.xlarge", "r5.xlarge"]
      override_instance_types  = ["m5.xlarge", "r5.xlarge"]
      spot_allocation_strategy = "lowest-price"
      spot_instance_pools      = 2
      asg_min_size             = 1
      asg_max_size             = 5
      asg_desired_capacity     = 1
      kubelet_extra_args       = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes      = ["AZRebalance"]
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

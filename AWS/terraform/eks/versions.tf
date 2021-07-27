terraform {
  required_version = ">= 1.0.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.49.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.3.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.2"
    }
  }

  backend "s3" {
    bucket = "doit-matt-tf-state-test"
    key    = "prod/eks/terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "doit-matt-tf-state-test"
    key    = "prod/terraform.tfstate"
    region = "us-west-2"
  }
}

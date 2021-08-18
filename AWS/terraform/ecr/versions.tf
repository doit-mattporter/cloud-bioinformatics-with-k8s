terraform {
  required_version = ">= 1.0.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.51.0"
    }
  }

  backend "s3" {
    bucket = "doit-matt-tf-state-test"
    key    = "prod/ecr/terraform.tfstate"
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

terraform {
  required_version = ">= 1.0.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.57.0"
    }

  }

  backend "s3" {
    bucket = "doit-matt-tf-state-test"
    key    = "prod/terraform.tfstate"
    region = "us-west-2"
  }
}

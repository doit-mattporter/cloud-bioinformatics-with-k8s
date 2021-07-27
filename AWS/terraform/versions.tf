terraform {
  required_version = ">= 1.0.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.49.0"
    }

  }

  backend "s3" {
    bucket = "doit-matt-tf-state-test"
    key    = "prod/terraform.tfstate"
    region = "us-west-2"
  }
}

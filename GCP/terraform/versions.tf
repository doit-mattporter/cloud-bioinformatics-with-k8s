terraform {
  required_version = ">= 1.0.4"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.80.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "= 1.11.3"
    }
  }

  backend "gcs" {
    bucket = "doit-matt-tf-state-test"
    prefix = "prod/terraform"
  }
}

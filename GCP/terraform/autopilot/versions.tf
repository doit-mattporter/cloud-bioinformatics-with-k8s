terraform {
  required_version = ">= 1.0.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.82.0"
    }
  }

  backend "gcs" {
    bucket = "doit-matt-tf-state-test"
    prefix = "prod/terraform"
  }
}

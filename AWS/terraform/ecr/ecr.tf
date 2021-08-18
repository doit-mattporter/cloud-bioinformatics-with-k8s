provider "aws" {
  profile = "default"
  region  = data.terraform_remote_state.vpc.outputs.aws_region
}

resource "aws_ecr_repository" "bwa-mem2" {
  name = "bwa-mem2"

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ecr_repository" "fastqc" {
  name = "fastqc"

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

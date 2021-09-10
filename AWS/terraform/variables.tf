# AWS variables
variable "aws_id" {
  type        = number
  description = "AWS Account ID"
}

variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "AWS Region to operate in"
}

variable "eks_cluster_name" {
  type        = string
  default     = "bioinformatics-tasks"
  description = "EKS cluster name"
}

variable "eks_vpc_cidr" {
  type        = string
  default     = "100.0.0.0/16"
  description = "CIDR block range for the EKS cluster"
}
# GCP variables
variable "gcp_project_id" {
  type        = string
  default     = "doit-matt-gke-test"
  description = "GCP Project ID"
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "GCP region to operate in"
}

variable "gke_cluster_name" {
  type        = string
  default     = "bioinformatics-tasks"
  description = "GKE cluster name"
}

variable "gke_vpc_cidr" {
  type        = string
  default     = "100.0.0.0/16"
  description = "CIDR block range for the GKE cluster"
}
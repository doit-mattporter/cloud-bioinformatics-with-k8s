variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name for bioinformatics tasks"
  default     = "bioinformatics-tasks"
}

variable "eks_version" {
  type        = string
  description = "EKS version to use"
  default     = "1.21"
}

variable "argo_workflow_version" {
  type        = string
  description = "Argo Workflow version to use"
  default     = "3.1.6"
}
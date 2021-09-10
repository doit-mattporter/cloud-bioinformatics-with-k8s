provider "aws" {
  profile = "default"
  region  = data.terraform_remote_state.eks.outputs.aws_region
}

resource "kubectl_manifest" "cloudwatch_namespace" {
  force_new = true
  yaml_body = data.http.cloudwatch_namespace_manifest_url.body
}

resource "kubectl_manifest" "fluentbit_daemon" {
  depends_on = [kubernetes_config_map.fluent-bit-cluster-info]
  count      = length(data.kubectl_file_documents.fluentbit_daemon_manifests.documents)
  yaml_body  = element(data.kubectl_file_documents.fluentbit_daemon_manifests.documents, count.index)
}

resource "kubectl_manifest" "argo_workflow" {
  depends_on         = [kubernetes_namespace.argo_ns]
  force_new          = true
  override_namespace = "argo"
  count              = length(data.kubectl_file_documents.argo_workflow_manifests.documents)
  yaml_body          = element(data.kubectl_file_documents.argo_workflow_manifests.documents, count.index)
}

resource "kubernetes_namespace" "argo_ns" {
  metadata {
    name = "argo"
  }
}

resource "kubernetes_namespace" "biojobs_ns" {
  metadata {
    name = "biojobs"
  }
}

resource "kubernetes_config_map" "fluent-bit-cluster-info" {
  depends_on = [kubectl_manifest.cloudwatch_namespace]
  metadata {
    name      = "fluent-bit-cluster-info"
    namespace = "amazon-cloudwatch"
  }

  data = {
    "cluster.name" = data.terraform_remote_state.eks.outputs.eks_cluster_name
    "http.server"  = "On"
    "http.port"    = "2020"
    "read.head"    = "Off"
    "read.tail"    = "On"
    "logs.region"  = data.terraform_remote_state.eks.outputs.aws_region
  }
}

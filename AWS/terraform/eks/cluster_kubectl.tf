resource "kubectl_manifest" "cloudwatch_namespace" {
  force_new = true
  yaml_body = data.http.cloudwatch_namespace_manifest_url.body
}

resource "kubectl_manifest" "fluentbit_daemon" {
  depends_on = [kubernetes_config_map.fluent-bit-cluster-info]
  count      = length(data.kubectl_file_documents.fluentbit_daemon_manifests.documents)
  yaml_body  = element(data.kubectl_file_documents.fluentbit_daemon_manifests.documents, count.index)
}

resource "kubernetes_config_map" "fluent-bit-cluster-info" {
  depends_on = [kubectl_manifest.cloudwatch_namespace]
  metadata {
    name      = "fluent-bit-cluster-info"
    namespace = "amazon-cloudwatch"
  }

  data = {
    "cluster.name" = var.eks_cluster_name
    "http.server"  = "On"
    "http.port"    = "2020"
    "read.head"    = "Off"
    "read.tail"    = "On"
    "logs.region"  = data.terraform_remote_state.vpc.outputs.aws_region
  }
}
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

resource "kubernetes_namespace" "biojobs" {
  metadata {
    name = "biojobs"
  }
}

resource "kubernetes_service_account" "biojobs-sa" {
  depends_on = [kubernetes_namespace.biojobs]
  metadata {
    name      = "biojobs-sa"
    namespace = "biojobs"
    annotations = {
      "iam.gke.io/gcp-service-account" : "${google_service_account.gke_bioinformatics_sa.name}@${var.gcp_project_id}"
    }
  }
}

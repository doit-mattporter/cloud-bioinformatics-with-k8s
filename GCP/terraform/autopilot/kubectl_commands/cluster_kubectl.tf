# Moved into its own separate terraform apply command downstream of GKE cluster creation due to issue created by the WARNING present here:
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
# https://itnext.io/terraform-dont-use-kubernetes-provider-with-your-cluster-resource-d8ec5319d14a

resource "kubectl_manifest" "argo_workflow" {
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
  metadata {
    name      = "biojobs-sa"
    namespace = "biojobs"
    annotations = {
      "iam.gke.io/gcp-service-account" : data.terraform_remote_state.gke.outputs.gke_cluster_bioinformatics_sa_email
    }
  }
}

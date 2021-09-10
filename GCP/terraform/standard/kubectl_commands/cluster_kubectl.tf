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

resource "kubernetes_namespace" "biojobs_ns" {
  metadata {
    name = "biojobs"
  }
}

resource "kubernetes_service_account" "biojobs-sa" {
  depends_on = [kubernetes_namespace.biojobs_ns] # Sometimes fails due to biojobs ns not being created first
  metadata {
    name      = "biojobs-sa"
    namespace = "biojobs"
    annotations = {
      "iam.gke.io/gcp-service-account" : data.terraform_remote_state.gke.outputs.gke_cluster_bioinformatics_sa_email
    }
  }
}

resource "kubernetes_role" "biojobs-sa-role" {
  # For enabling argo
  depends_on = [kubernetes_namespace.biojobs_ns] # Sometimes fails due to biojobs ns not being created first
  metadata {
    name      = "biojobs-sa-role"
    namespace = "biojobs"
  }
  # pod get/watch is used to identify the container IDs of the current pod
  # pod patch is used to annotate the step's outputs back to controller (e.g. artifact location)
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "watch", "patch"]
  }
  # logs get/watch are used to get the pods logs for script outputs, and for log archival
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "watch"]
  }
}

resource "kubernetes_role_binding" "biojobs-sa-role-binding" {
  depends_on = [kubernetes_namespace.biojobs_ns] # Sometimes fails due to biojobs ns not being created first
  metadata {
    name      = "biojobs-sa-role-binding"
    namespace = "biojobs"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "biojobs-sa-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "biojobs-sa"
    namespace = "biojobs"
  }
}

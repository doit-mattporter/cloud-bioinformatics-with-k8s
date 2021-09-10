data "google_client_config" "current" {}

data "http" "argo_workflow_manifest_url" {
  url = "https://raw.githubusercontent.com/argoproj/argo-workflows/master/manifests/install.yaml"
}

# Manifests are split up
data "kubectl_file_documents" "argo_workflow_manifests" {
  content = data.http.argo_workflow_manifest_url.body
}

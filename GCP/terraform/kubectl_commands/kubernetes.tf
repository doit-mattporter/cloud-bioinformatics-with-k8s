provider "kubernetes" {
  host                   = data.terraform_remote_state.gke.outputs.gke_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.gke.outputs.gke_cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "kubectl" {
  load_config_file       = false
  host                   = data.terraform_remote_state.gke.outputs.gke_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.gke.outputs.gke_cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

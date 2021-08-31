provider "kubernetes" {
  host                   = google_container_cluster.bioinformatics_tasks.endpoint
  cluster_ca_certificate = base64decode(google_container_cluster.bioinformatics_tasks.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "kubectl" {
  load_config_file = false
  host                   = google_container_cluster.bioinformatics_tasks.endpoint
  cluster_ca_certificate = base64decode(google_container_cluster.bioinformatics_tasks.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

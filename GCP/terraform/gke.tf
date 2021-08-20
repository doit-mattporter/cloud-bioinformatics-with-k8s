provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_service_account" "gke_default_sa" {
  depends_on   = [google_project_service.container]
  account_id   = "gke-default-sa-id"
  display_name = "GKE Default Service Account"
}

resource "google_container_cluster" "bioinformatics_tasks" {
  depends_on       = [google_project_service.compute]
  name             = "bioinformatics-tasks"
  location         = var.gcp_region
  enable_autopilot = true
  node_config {
    disk_size_gb = 512
    preemptible  = true
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_container_cluster" "bioinformatics_tasks" {
  name             = "bioinformatics-tasks"
  location         = var.gcp_region
  enable_autopilot = true
  release_channel {
    channel = "RAPID"
  }
  # node_config {
  #   disk_size_gb = 512
  # }
}

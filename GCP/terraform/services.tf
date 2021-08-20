resource "google_project_service" "compute" {
  project = var.gcp_project_id
  service = "compute.googleapis.com"

  timeouts {
    create = "10m"
    update = "10m"
  }

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "container" {
  project = var.gcp_project_id
  service = "container.googleapis.com"

  timeouts {
    create = "10m"
    update = "10m"
  }

  disable_dependent_services = false
  disable_on_destroy         = false
}
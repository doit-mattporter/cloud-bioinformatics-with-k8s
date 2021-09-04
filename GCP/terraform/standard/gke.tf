provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_container_cluster" "bioinformatics_tasks" {
  name                     = "bioinformatics-tasks"
  location                 = var.gcp_region
  enable_shielded_nodes    = true
  remove_default_node_pool = true
  initial_node_count       = 1
  workload_identity_config {
    identity_namespace = "${var.gcp_project_id}.svc.id.goog"
  }
  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum       = 2
      maximum       = 160
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 128
      maximum       = 640
    }
  }
}

resource "google_container_node_pool" "ephemeral_highcpu_preemptible_node_pool" {
  name       = "ephemeral-highcpu-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.bioinformatics_tasks.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n2-standard-32"
    disk_size_gb = 600
    shielded_instance_config {
      enable_secure_boot = true
    }
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
    service_account = google_service_account.gke_cluster_bioinformatics_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

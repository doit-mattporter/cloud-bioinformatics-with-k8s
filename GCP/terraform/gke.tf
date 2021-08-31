provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_service_account" "gke_bioinformatics_sa" {
  depends_on   = [google_project_service.container]
  account_id   = "gke-bioinformatics-sa-id"
  display_name = "GKE Bioinformatics Cluster Service Account"
}

resource "google_service_account_iam_binding" "associate-workload-identity-user" {
  depends_on         = [kubernetes_service_account.biojobs-sa]
  service_account_id = google_service_account.gke_bioinformatics_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.gcp_project_id}.svc.id.goog[biojobs/biojobs-sa]",
  ]
}

resource "google_service_account_iam_binding" "associate-sa-token-creator" {
  depends_on         = [kubernetes_service_account.biojobs-sa]
  service_account_id = google_service_account.gke_bioinformatics_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:${var.gcp_project_id}.svc.id.goog[biojobs/biojobs-sa]",
  ]
}

resource "google_container_cluster" "bioinformatics_tasks" {
  depends_on       = [google_project_service.compute]
  name             = "bioinformatics-tasks"
  location         = var.gcp_region
  enable_autopilot = true
  release_channel {
    channel = "RAPID"
  }
  node_config {
    disk_size_gb    = 512
    preemptible     = true
    service_account = google_service_account.gke_bioinformatics_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

  }
}

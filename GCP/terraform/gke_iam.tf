resource "google_service_account" "gke_cluster_bioinformatics_sa" {
  account_id   = "gke-bioinformatics-sa"
  display_name = "GKE Bioinformatics Cluster Service Account"
}

resource "google_service_account_iam_binding" "associate-workload-identity-user" {
  service_account_id = google_service_account.gke_cluster_bioinformatics_sa.email
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.gcp_project_id}.svc.id.goog[biojobs/biojobs-sa]",
  ]
}

resource "google_project_iam_member" "associate-gcs-obj-admin" {
  project = var.gcp_project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.gke_cluster_bioinformatics_sa.email}"
}

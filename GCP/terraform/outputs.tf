output "gcp_project_id" {
  value = var.gcp_project_id
}

output "gcp_region" {
  value = var.gcp_region
}

output "gke_cluster_name" {
  value = var.gke_cluster_name
}

output "gke_cluster_bioinformatics_sa" {
  value = google_service_account.gke_cluster_bioinformatics_sa.name
}

output "gke_cluster_endpoint" {
  value = google_container_cluster.bioinformatics_tasks.endpoint
}

output "gke_cluster_ca_certificate" {
  value = base64decode(google_container_cluster.bioinformatics_tasks.master_auth.0.cluster_ca_certificate)
}
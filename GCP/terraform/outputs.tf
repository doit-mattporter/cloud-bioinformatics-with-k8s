output "gcp_region" {
  value = var.gcp_region
}

output "gke_cluster_name" {
  value = var.gke_cluster_name
}

output "gke_cluster_endpoint" {
  value = google_container_cluster.bioinformatics_tasks.endpoint
}
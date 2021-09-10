data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.eks_cluster_id
}

data "http" "argo_workflow_manifest_url" {
  url = "https://raw.githubusercontent.com/argoproj/argo-workflows/master/manifests/install.yaml"
}

# Manifests are split up
data "kubectl_file_documents" "argo_workflow_manifests" {
  content = data.http.argo_workflow_manifest_url.body
}

data "http" "cloudwatch_namespace_manifest_url" {
  url = "https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml"
}

data "http" "fluentbit_manifest_url" {
  url = "https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml"
}

# Manifests split from step 3 here: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs-FluentBit.html
data "kubectl_file_documents" "fluentbit_daemon_manifests" {
  content = data.http.fluentbit_manifest_url.body
}

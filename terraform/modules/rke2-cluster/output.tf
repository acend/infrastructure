output "kubernetes_api_host" {
  value = local.kubernetes_api_host
}

output "kubeconfig" {
  value = local.kubeconfig
}

output "kubeconfig_raw" {
  value = local.kubeconfig_raw
}

output "argocd-admin-secret" {
  value = data.kubernetes_secret.admin-secret.data.password
}
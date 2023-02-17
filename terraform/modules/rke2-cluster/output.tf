output "kubernetes_api" {
  value = local.kubernetes_api
}

output "kubernetes_api_ipv4" {
  value = local.kubernetes_api_ipv6
}

output "kubernetes_api_ipv6" {
  value = local.kubernetes_api_ipv6
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
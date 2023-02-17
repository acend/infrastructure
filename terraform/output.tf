output "kubernetes_api" {
  value = module.acend-cluster.kubernetes_api
}

output "kubernetes_api_ipv4" {
  value = module.acend-cluster.kubernetes_api_ipv4
}

output "kubernetes_api_ipv6" {
  value = module.acend-cluster.kubernetes_api_ipv6
}

output "kubeconfig" {
  value     = module.acend-cluster.kubeconfig
  sensitive = true
}

output "kubeconfig_raw" {
  value     = module.acend-cluster.kubeconfig_raw
  sensitive = true
}

output "argocd-admin-secret" {
  value     = module.acend-cluster.argocd-admin-secret
  sensitive = true
}
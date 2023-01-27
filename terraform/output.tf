output "kubernetes_api_host" {
  value = module.acend-cluster.kubernetes_api_host
}

output "kubeconfig" {
  value = module.acend-cluster.kubeconfig
  sensitive = true
}

output "kubeconfig_raw" {
  value = module.acend-cluster.kubeconfig_raw
  sensitive = true
}

output "argocd-admin-secret" {
  value = module.acend-cluster.argocd-admin-secret
  sensitive = true
}
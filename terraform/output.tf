output "kubernetes_api_host" {
  value = module.acend-cluster.kubernetes_api_host
}

output "kubeconfig" {
  value = module.acend-cluster.kubeconfig
}

output "kubeconfig_raw" {
  value = module.acend-cluster.kubeconfig_raw
}

output "argocd-admin-secret" {
  value = module.acend-cluster.argocd-admin-secret
}
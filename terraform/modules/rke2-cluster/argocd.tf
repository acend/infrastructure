resource "kubernetes_namespace" "argocd" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]
  metadata {
    name = "argocd"
  }
}

data "kubernetes_secret" "admin-secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }

  depends_on = [
    helm_release.argocd
  ]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  version    = "7.6.12"

  values = [
    templatefile("${path.module}/templates/argocd-values.yaml", {
      cluster-domain                 = var.cluster-domain
      github-app-argocd-clientSecret = var.github-app-argocd-clientSecret
    }),
  ]
}

resource "helm_release" "argocd-bootstrap" {
  name       = "argocd-bootstrap"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  version    = "2.0.2"

  values = [
    templatefile("${path.module}/templates/argocd-bootstrap-values.yaml", {
      namespace = helm_release.argocd.namespace
    }),
  ]
}

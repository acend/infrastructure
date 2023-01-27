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
  version    = "5.19.9"

  values = [
    templatefile("${path.module}/templates/argocd-values.yaml", {
      cluster-domain = var.cluster-domain
    }),
  ]

}

resource "helm_release" "argocd-bootstrap" {
  name       = "argocd-bootstrap"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  version    = "0.0.6"

  values = [
    templatefile("${path.module}/templates/argocd-bootstrap-values.yaml", {
      namespace = helm_release.argocd.namespace
    }),
  ]

}

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
  version    = "5.19.8"
  
  values = [
    templatefile("${path.module}/templates/argocd-values.yaml", {
        cluster-domain = var.cluster-domain
    }),
  ]

}

# This can only be applied after the argocd installation, as the CRDs are missing and this terraform provider currently can not work with this
# See https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367
# resource "kubernetes_manifest" "bootstrap" {
#   manifest = {
#     "apiVersion" = "argoproj.io/v1alpha1"
#     "kind"       = "Application"
#     "metadata" = {
#       "name"      = "bootstrap"
#       "namespace" = helm_release.argocd.namespace
#     }
#     "spec" = {
#       "project": "default"
#       "source": {
#         "repoURL": "https://github.com/acend/infrastructure.git"
#         "ragetRevision": "HEAD"
#         "path": "deploy/bootstrap"
#       }
#       "destination": {
#         "server": "https://kubernetes.default.svc"
#         "namespace": helm_release.argocd.namespace
#       }
#     }
#   }
# }
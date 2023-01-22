resource "kubernetes_namespace" "flux" {
  metadata {

    name = "flux-system"
  }
}

resource "helm_release" "flux" {
  name = "flux"

  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"

  namespace = kubernetes_namespace.flux.metadata.0.name

  values = [
    templatefile(
      "${path.module}/templates/flux-values.yaml", {
      }
    )
  ]
}

resource "helm_release" "flux2-sync" {
  depends_on = [
    helm_release.flux
  ]
  name = "flux2-sync"

  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2-sync"

  namespace = kubernetes_namespace.flux.metadata.0.name

  values = [
    templatefile(
      "${path.module}/templates/fluxsync-values.yaml", {
        giturl = "ssh://git@github.com/acend/infrastructure"
      }
    )
  ]
}
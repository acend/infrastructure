resource "kubernetes_namespace" "flux" {
  metadata {

    name = "flux"
  }
}

resource "helm_release" "flux" {
  name = "flux"

  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "nginx-ingress-controller"

  namespace = kubernetes_namespace.flux.metadata.0.name

  values = [
    templatefile(
      "${path.module}/templates/flux-values.yaml", {
      }
    )
  ]
}
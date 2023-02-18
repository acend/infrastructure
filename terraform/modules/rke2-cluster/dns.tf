resource "restapi_object" "lb-api-a-record" {
  provider = restapi.hosttech_dns
  path = "/api/user/v1/zones/${var.hosttech-dns-zone-id}/records"
  data = "{\"type\": \"A\",\"name\": \"k8s-${var.clustername}\",\"ipv4\": \"${hcloud_load_balancer.lb.ipv4}\",\"ttl\": 3600,\"comment\": \"K8s API for Cluster ${var.clustername}\"}"
  id_attribute = "data/id"
}

resource "restapi_object" "lb-api-aaaa-record" {
  provider = restapi.hosttech_dns
  path = "/api/user/v1/zones/${var.hosttech-dns-zone-id}/records"
  data = "{\"type\": \"AAAA\",\"name\": \"k8s-${var.clustername}\",\"ipv6\": \"${hcloud_load_balancer.lb.ipv6}\",\"ttl\": 3600,\"comment\": \"K8s API for Cluster ${var.clustername}\"}"
  id_attribute = "data/id"
}


data "kubernetes_service" "ingress-nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  count = var.first_install ? 0 : 1
}

resource "restapi_object" "ingress-a-record" {
  provider = restapi.hosttech_dns
  path = "/api/user/v1/zones/${var.hosttech-dns-zone-id}/records"
  data = "{\"type\": \"A\",\"name\": \"*.k8s-${var.clustername}\",\"ipv4\": \"${data.kubernetes_service.ingress-nginx.0.status.0.load_balancer.0.ingress.0.ip}\",\"ttl\": 3600,\"comment\": \"Ingress Controller LB\"}"
  id_attribute = "data/id"

  // Only after initial installation, the nginx lb svc is available.
  count = var.first_install ? 0 : 1

}

resource "restapi_object" "ingress-aaaa-record" {
  provider = restapi.hosttech_dns
  path = "/api/user/v1/zones/${var.hosttech-dns-zone-id}/records"
  data = "{\"type\": \"AAAA\",\"name\": \"*.k8s-${var.clustername}\",\"ipv6\": \"${data.kubernetes_service.ingress-nginx.0.status.0.load_balancer.0.ingress.1.ip}\",\"ttl\": 3600,\"comment\": \"Ingress Controller LB\"}"
  id_attribute = "data/id"

  count = var.first_install ? 0 : 1
}
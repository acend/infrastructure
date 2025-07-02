resource "kubernetes_secret" "hcloud" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]
  metadata {
    name      = "hcloud"
    namespace = "kube-system"
  }

  data = {
    token   = var.hcloud_api_token
    network = hcloud_network.network.id
  }

  type = "Opaque"
}

resource "kubernetes_secret" "cloud-controller-manager" {
  depends_on = [
    time_sleep.wait_for_k8s_api
  ]
  metadata {
    name = "cloud-controller-manager"
  }
}

resource "kubernetes_service_account" "cloud-controller-manager" {
  metadata {
    name      = "cloud-controller-manager"
    namespace = "kube-system"
  }
  secret {
    name = kubernetes_secret.cloud-controller-manager.metadata.0.name
  }
}

resource "kubernetes_cluster_role_binding" "cloud-controller-manager" {
  metadata {
    name = "system:cloud-controller-manager"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cloud-controller-manager.metadata.0.name
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "cloud-controller-manager" {

  lifecycle {
    ignore_changes = [
      spec[0].template[0].spec[0].toleration
    ]
  }

  metadata {
    name      = "hcloud-cloud-controller-manager"
    namespace = "kube-system"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "hcloud-cloud-controller-manager"
      }
    }

    template {
      metadata {
        labels = {
          app = "hcloud-cloud-controller-manager"
        }
      }

      spec {

        service_account_name = kubernetes_service_account.cloud-controller-manager.metadata.0.name
        dns_policy           = "Default"

        toleration {
          key    = "node.cloudprovider.kubernetes.io/uninitialized"
          value  = "true"
          effect = "NoSchedule"
        }

        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }

        toleration {
          key    = "node-role.kubernetes.io/control-plane"
          value  = "true"
          effect = "NoSchedule"
        }

        toleration {
          key    = "node-role.kubernetes.io/master"
          value  = "true"
          effect = "NoSchedule"
        }

        toleration {
          key    = "node.kubernetes.io/not-ready"
          value  = "true"
          effect = "NoSchedule"
        }

        node_selector = {
          "node-role.kubernetes.io/control-plane" = "true"
        }

        host_network = true

        priority_class_name = "system-cluster-critical"

        container {
          image = "hetznercloud/hcloud-cloud-controller-manager:v1.26.0"
          name  = "hcloud-cloud-controller-manager"

          resources {
            requests = {
              cpu    = "100m"
              memory = "50Mi"
            }
          }

          command = [
            "/bin/hcloud-cloud-controller-manager",
            "--cloud-provider=hcloud",
            "--leader-elect=false",
            "--allow-untagged-cloud",
            "--allocate-node-cidrs=true",
            "--route-reconciliation-period=30s",
            "--cluster-cidr=${var.k8s-cluster-cidr}"
          ]

          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "HCLOUD_TOKEN"
            value_from {
              secret_key_ref {
                key  = "token"
                name = kubernetes_secret.hcloud.metadata.0.name
              }
            }
          }

          env {
            name = "HCLOUD_NETWORK"
            value_from {
              secret_key_ref {
                key  = "network"
                name = kubernetes_secret.hcloud.metadata.0.name
              }
            }
          }

          env {
            name  = "HCLOUD_LOAD_BALANCERS_NETWORK_ZONE"
            value = var.networkzone
          }

          env {
            name  = "HCLOUD_LOAD_BALANCERS_USE_PRIVATE_IP"
            value = "true"
          }



        }
      }

    }

  }
}
provider "hcloud" {
  token = var.hcloud_api_token
}

provider "kubernetes" {
  # On initial deploy, use this to get the credentials via ssh from rke2
  # Afterwards, update variables and change to them
  # host                   = local.kubernetes_api_host
  # client_certificate     = local.client_certificate
  # client_key             = local.client_key
  # cluster_ca_certificate = local.cluster_ca_certificate

  host                   = var.provider-k8s-api-host
  client_certificate     = base64decode(nonsensitive(var.provider-client-certificate))
  client_key             = base64decode(nonsensitive(var.provider-client-key))
  cluster_ca_certificate = base64decode(var.provider-cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    # On initial deploy, use this to get the credentials via ssh from rke2
    # Afterwards, update variables and change to them
    # host                   = local.kubernetes_api_host
    # client_certificate     = local.client_certificate
    # client_key             = local.client_key
    # cluster_ca_certificate = local.cluster_ca_certificate

    host                   = var.provider-k8s-api-host
    client_certificate     = base64decode(nonsensitive(var.provider-client-certificate))
    client_key             = base64decode(nonsensitive(var.provider-client-key))
    cluster_ca_certificate = base64decode(var.provider-cluster_ca_certificate)

  }
}

resource "hcloud_network" "network" {
  name     = var.clustername
  ip_range = var.network
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.network.id
  type         = "cloud"
  network_zone = var.networkzone
  ip_range     = var.subnetwork
}

resource "hcloud_load_balancer" "lb" {
  name               = "lb-k8s"
  load_balancer_type = var.lb_type
  location           = var.location

  labels = {
    cluster : var.clustername,
  }
}

resource "hcloud_load_balancer_network" "lb" {
  load_balancer_id = hcloud_load_balancer.lb.id
  network_id       = hcloud_network.network.id
  ip               = var.internalbalancerip
}

resource "hcloud_load_balancer_service" "rke2" {
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "tcp"
  listen_port      = 9345
  destination_port = 9345
  health_check {
    protocol = "tcp"
    port     = 9345
    interval = 5
    timeout  = 2
    retries  = 5
  }
}

resource "hcloud_load_balancer_service" "api" {
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
  health_check {
    protocol = "tcp"
    port     = 6443
    interval = 5
    timeout  = 2
    retries  = 2
  }
}

resource "hcloud_load_balancer_target" "controlplane" {
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.lb.id
  label_selector   = "cluster=${var.clustername},controlplane=true"
  use_private_ip   = true
  depends_on       = [hcloud_load_balancer_network.lb]
}

resource "hcloud_firewall" "firewall" {
  name = "k8s-cluster"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "9345"
    source_ips = [for server in hcloud_server.controlplane : "${server.ipv4_address}/32"]
  }

  apply_to {
    label_selector = "cluster=${var.clustername}"
  }
}

resource "random_password" "rke2_cluster_secret" {
  length  = 256
  special = false
}

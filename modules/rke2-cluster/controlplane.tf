resource "hcloud_placement_group" "controlplane" {
  name = "controlplane"
  type = "spread"
  labels = {
    cluster : var.clustername,
    controlplane : "true"
  }
}

resource "hcloud_server" "controlplane" {
  count = var.controlplane_count

  name        = "${var.clustername}-controlplane-${count.index}"
  location    = var.location
  image       = var.node_image_type
  server_type = var.controlplane_type

  placement_group_id = hcloud_placement_group.controlplane.id

  labels = {
    cluster : var.clustername,
    controlplane : "true"
  }

  ssh_keys = [hcloud_ssh_key.terraform.name]

  user_data = templatefile("${path.module}/templates/cloudinit-controlplane.yaml", {
    api_token = var.hcloud_api_token,

    clustername = var.clustername,

    rke2_version        = var.rke2_version,
    rke2_cluster_secret = random_password.rke2_cluster_secret.result

    extra_ssh_keys = var.extra_ssh_keys,

    lb_id          = hcloud_load_balancer.lb.id,
    lb_address     = hcloud_load_balancer_network.lb.ip,
    lb_external_v4 = hcloud_load_balancer.lb.ipv4,
    lb_external_v6 = hcloud_load_balancer.lb.ipv6,

    controlplane_index = count.index,

    domains = var.domains

    k8s-cluster-cidr = var.k8s-cluster-cidr
  })
}

resource "hcloud_server_network" "controlplane" {
  count      = var.controlplane_count
  server_id  = hcloud_server.controlplane[count.index].id
  network_id = hcloud_network.network.id
}

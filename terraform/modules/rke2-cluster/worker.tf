resource "hcloud_server" "worker" {
  count = var.worker_count

  lifecycle {
    ignore_changes = [
      # Ignore user_data for existing nodes as this requires a replacement
      user_data
    ]
  }


  name        = "${var.clustername}-worker-${count.index}"
  location    = var.location
  image       = var.node_image_type
  server_type = var.worker_type

  labels = {
    cluster : var.clustername,
    worker : "true"
  }

  ssh_keys = [hcloud_ssh_key.terraform.name]

  user_data = templatefile("${path.module}/templates/cloudinit-worker.yaml", {
    api_token = var.hcloud_api_token,

    clustername = var.clustername,

    rke2_version        = var.rke2_version,
    rke2_cluster_secret = random_password.rke2_cluster_secret.result,

    extra_ssh_keys = var.extra_ssh_keys,

    lb_address = hcloud_load_balancer_network.lb.ip,
    lb_id      = hcloud_load_balancer.lb.id,

    worker_index = count.index
  })
}

resource "hcloud_server_network" "worker" {
  count      = var.worker_count
  server_id  = hcloud_server.worker[count.index].id
  network_id = hcloud_network.network.id
}


resource "kubernetes_secret" "cloud_init_worker" {
  metadata {
    name      = "cloud-init-worker"
    namespace = "kube-system"
  }

  data = {
    "cloudinit.yaml" = base64encode(templatefile("${path.module}/templates/cloudinit-worker.yaml", {
      api_token = var.hcloud_api_token,

      clustername = var.clustername,

      rke2_version        = var.rke2_version,
      rke2_cluster_secret = random_password.rke2_cluster_secret.result,

      extra_ssh_keys = var.extra_ssh_keys,

      lb_address = hcloud_load_balancer_network.lb.ip,
      lb_id      = hcloud_load_balancer.lb.id,
    }))
  }

  type = "Opaque"
}
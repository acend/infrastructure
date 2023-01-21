locals {
  kubernetes_api_host    = "https://${hcloud_load_balancer.lb.ipv4}:6443"
  kubeconfig_raw         = replace(ssh_resource.getkubeconfig.result, "server: https://127.0.0.1:6443", "server: https://${hcloud_load_balancer.lb.ipv4}:6443")
  kubeconfig             = yamldecode(local.kubeconfig_raw)
  client_certificate     = base64decode(local.kubeconfig.users[0].user.client-certificate-data)
  client_key             = base64decode(local.kubeconfig.users[0].user.client-key-data)
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster.certificate-authority-data)
}

// Wait a bit to make sure k8s api is up and running
resource "time_sleep" "wait_120_seconds" {
  depends_on = [
    hcloud_server.controlplane
  ]
  create_duration = "120s"
}


resource "ssh_resource" "getkubeconfig" {

  depends_on = [
    time_sleep.wait_120_seconds
  ]

  when = "create"

  host = hcloud_server.controlplane[0].ipv4_address
  user = "root"

  private_key = tls_private_key.terraform.private_key_openssh

  timeout     = "15m"
  retry_delay = "5s"

  commands = [
    "until [ -f /etc/rancher/rke2/rke2.yaml ]; do sleep 10; done;",
    "cat /etc/rancher/rke2/rke2.yaml"
  ]
}

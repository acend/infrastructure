terraform {
  backend "remote" {}
}


module "acend-cluster" {
  source = "./modules/rke2-cluster"

  clustername = var.clustername

  rke2_version = var.rke2_version

  k8s_api_hostnames = var.k8s_api_hostnames

  hcloud_api_token = var.hcloud_api_token

  extra_ssh_keys     = var.extra_ssh_keys
  controlplane_count = var.controlplane_count
  worker_count       = var.worker_count

  provider-client-key             = var.provider-client-key
  provider-client-certificate     = var.provider-client-certificate
  provider-cluster_ca_certificate = var.provider-cluster_ca_certificate
  provider-k8s-api-host           = var.provider-k8s-api-host

}

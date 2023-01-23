terraform {
  backend "remote" {}
}


module "acend-cluster" {
  source = "./modules/rke2-cluster"

  clustername  = "acend"
  rke2_version = "v1.26.0+rke2r1"
  domains      = ["k8s.acend.ch"]

  hcloud_api_token = var.hcloud_api_token
  extra_ssh_keys   = var.extra_ssh_keys

}

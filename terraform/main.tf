terraform {
  backend "remote" {}
}


module "acend-cluster" {
  source = "./modules/rke2-cluster"

  delete_protection = var.delete_protection

  clustername = var.clustername

  rke2_version = var.rke2_version

  k8s_api_hostnames = var.k8s_api_hostnames

  hcloud_api_token   = var.hcloud_api_token
  hosttech_dns_token = var.hosttech_dns_token

  hosttech-dns-zone-id = var.hosttech-dns-zone-id

  extra_ssh_keys     = var.extra_ssh_keys
  controlplane_count = var.controlplane_count
  worker_count       = var.worker_count

  ## Helm and Kubernetes Provider Config
  provider-client-key             = var.provider-client-key
  provider-client-certificate     = var.provider-client-certificate
  provider-cluster_ca_certificate = var.provider-cluster_ca_certificate
  provider-k8s-api-host           = var.provider-k8s-api-host

  cluster-domain = var.cluster-domain

  ## ArgoCD Config
  github-app-argocd-clientSecret = var.github-app-argocd-clientSecret

  first_install = var.first_install

}

provider "minio" {
  minio_server   = "fsn1.your-objectstorage.com"
  minio_user     = "${var.hcloud_s3_access_key}"
  minio_password = "${var.hcloud_s3_secret_key}"
  minio_region   = "nbg1"
  minio_ssl      = true
}

resource "minio_s3_bucket" "acend" {
  bucket         = "acend"
  acl            = "private"
  object_locking = false

}
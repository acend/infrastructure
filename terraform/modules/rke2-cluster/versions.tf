terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.36.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.8.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.3.0"
    }
  }
}

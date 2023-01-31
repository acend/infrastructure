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
      version = "2.17.0"
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

  required_version = ">= 1.3.3"
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.48.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.33.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.20.0"
    }
  }

  required_version = ">= 1.3.3"
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.39.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.6.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.18.0"
    }
  }

  required_version = ">= 1.3.3"
}

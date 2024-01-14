terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.45.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.6.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.18.2"
    }
  }

  required_version = ">= 1.3.3"
}

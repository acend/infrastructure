variable "hcloud_api_token" {
  type        = string
  description = "hetzner api token with read permission to read lb state"
}

variable "hosttech_dns_token" {
  type        = string
  description = "hosttech dns api token"
}

variable "hosttech-dns-zone-id" {
  type        = string
  description = "Zone ID of the hosttech DNS Zone where LoadBalancer A/AAAA records are created"
}

variable "first_install" {
  type        = bool
  default     = false
  description = "Indicate if this is the very first installation. RKE2 needs to handle the first controlplane node special when its the initial installation"
}

variable "extra_ssh_keys" {
  type        = list(any)
  default     = []
  description = "Extra ssh keys to inject into Rancher instances"
}

variable "controlplane_count" {
  type        = number
  default     = 3
  description = "Count of rke2 servers"

  validation {
    condition     = var.controlplane_count == 3
    error_message = "You must have 3 control plane nodes."
  }
}

variable "worker_count" {
  type        = number
  default     = 2
  description = "Count of rke2 workers"
}

variable "k8s_api_hostnames" {
  type        = list(string)
  description = "Host Name of K8S API, added as SAN to API Certificate"
}

variable "clustername" {
  type        = string
  description = "name of the cluster"
  default     = "acend"
}

variable "rke2_version" {
  type        = string
  default     = "v1.27.6+rke2r1"
  description = "Version of rke2 to install"
}

variable "provider-client-key" {
  type = string
}

variable "provider-client-certificate" {
  type = string
}

variable "provider-cluster_ca_certificate" {
  type = string
}

variable "provider-k8s-api-host" {
  type = string
}

variable "cluster-domain" {
  type        = string
  description = "default domain used for example by ingress resources"
  default     = "k8s-prod.acend.ch"
}

variable "github-app-argocd-clientSecret" {
  type        = string
  description = "The client Secret for the ArgoCD Github Authentication"
}

variable "delete_protection" {
  type        = bool
  description = "If true, prevent deletion of resources"
  default     = true
}
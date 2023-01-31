variable "hcloud_api_token" {
  type        = string
  description = "hetzner api token with read permission to read lb state"
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
  default     = "v1.26.0+rke2r2"
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
  default     = "k8s.labz.ch"
}

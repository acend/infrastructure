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
  default     = 3
  description = "Count of rke2 servers"
}

variable "worker_count" {
  default     = 2
  description = "Count of rke2 workers"
}

variable "k8s_api_hosts" {
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
  default     = "v1.26.0+rke2r1"
  description = "Version of rke2 to install"
}
variable "hcloud_api_token" {
  type        = string
  description = "hetzner api token with read permission to read lb state"
}

variable "location" {
  type        = string
  default     = "nbg1"
  description = "hetzner location"
}

variable "clustername" {
  type        = string
  description = "name of the cluster"
}

variable "rke2_version" {
  type        = string
  default     = "v1.26.0+rke2r1"
  description = "Version of rke2 to install"
}

variable "network" {
  type        = string
  default     = "10.0.0.0/8"
  description = "network to use"
}
variable "subnetwork" {
  type        = string
  default     = "10.0.0.0/24"
  description = "subnetwork to use"
}
variable "networkzone" {
  type        = string
  default     = "eu-central"
  description = "hetzner netzwork zone"
}


variable "internalbalancerip" {
  type        = string
  default     = "10.0.0.2"
  description = "IP to use for control plane loadbalancer"
}
variable "lb_type" {
  type        = string
  default     = "lb11"
  description = "Load balancer type"
}

variable "node_image_type" {
  type        = string
  default     = "ubuntu-22.04"
  description = "Image Type for all Nodes"
}

variable "controlplane_count" {
  default     = 3
  description = "Count of rke2 servers"
}

variable "worker_count" {
  default     = 2
  description = "Count of rke2 workers"
}


variable "controlplane_type" {
  type        = string
  default     = "CPX31"
  description = "machine type to use for the controlplanes"
}

variable "worker_type" {
  type        = string
  default     = "CPX41"
  description = "machine type to use for the controlplanes"
}

variable "extra_ssh_keys" {
  type        = list(any)
  default     = []
  description = "Extra ssh keys to inject into vm's"
}

variable "k8s_api_hosts" {
  type        = list(string)
  description = "Host Name of K8S API, added as SAN to API Certificate"
}

variable "k8s-cluster-cidr" {
  default = "10.244.0.0/16"
}

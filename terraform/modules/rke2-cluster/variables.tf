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
  default     = "v1.29.2+rke2r1"
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
  default     = "cpx31"
  description = "machine type to use for the controlplanes"
}

variable "worker_type" {
  type        = string
  default     = "cpx41"
  description = "machine type to use for the controlplanes"
}

variable "extra_ssh_keys" {
  type        = list(any)
  default     = []
  description = "Extra ssh keys to inject into vm's"
}

variable "k8s_api_hostnames" {
  type        = list(string)
  description = "Host Name of K8S API, added as SAN to API Certificate"
}

variable "k8s-cluster-cidr" {
  default = "10.244.0.0/16"
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
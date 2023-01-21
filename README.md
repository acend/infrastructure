# infrastructure
IaC for acend kubernetes resources

This repo creates the basic acned infrastructure using terraform and kubernetes resource files.

We use [Hetzner](https://www.hetzner.com/cloud) as our cloud provider.

[RKE2](https://docs.rke2.io/) is used to create the kubernetes cluster

[Kubernetes Cloud Controller Manager for Hetzner Cloud](https://github.com/hetznercloud/hcloud-cloud-controller-manager) is used to provision Load Balancer from Kubernetes Service (Type Loadbalancer) objects

## Dependencies

* Terraform

### Terraform provider & modules

* [Hetzner Cloud Provider](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)
* [kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest)
* [helm](https://registry.terraform.io/providers/hashicorp/helm/latest)
* [tls]https://registry.terraform.io/providers/hashicorp/tls/latest
* [SSH Terraform Provider](https://registry.terraform.io/providers/loafoe/ssh/latest)
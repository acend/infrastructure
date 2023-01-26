# infrastructure

IaC for acend kubernetes resources

This repo creates the basic acend infrastructure using terraform.

We use [Hetzner](https://www.hetzner.com/cloud) as our cloud provider and [RKE2](https://docs.rke2.io/) is used to create the kubernetes cluster.[Kubernetes Cloud Controller Manager for Hetzner Cloud](https://github.com/hetznercloud/hcloud-cloud-controller-manager) is used to provision lobalancer from a Kubernetes service (type `Loadbalancer`) objects and also configure the networking & native routing for the Kubernetes cluster network traffic.

[Flux](https://fluxcd.io/) is used to deploy resourcen on the Kubernetes Cluster

Folder structure:

* `deploy`: Resources for flux application deployment
* `terraform`: All terraform files for infrastructure deployment

## Workflow

1. Terraform to deploy base infrastructure
   * VM's for controlplane and worker nodes
   * Network
   * Loadbalancer for Kubernetes API and RKE2
   * Firewall
   * Hetzner Cloud Controller Manager for the Kubernetes Cluster Networking
2. Terraform to delploy and bootstrap flux
3. Flux to deploy resources on the Kubernetes Cluster

```mermaid
flowchart LR
    A[Git Repository]
    A --> B{Terraform Cloud}

    B --> C{Hetzner Cloud}

    C -- deploy ---> C1{Loadbalancer}
    C1 -- with service ---> C11{K8s API 6443}
    C1 -- withservice ---> C12{RKE2 API 9345}
    C -- deploy ---> C2{Control Plane VM's}
    C -- deploy ---> C3{Worker VM's}
    C -- deploy ---> C4{Private Network}
    C4 --> C41{Subnet for Nodes}
    C -- deploy ---> C5{Firewall}
    C2 -- configure ---> cloudinit
    C3 -- configure ---> cloudinit
    
    B-- initial bootstrap -->D

    A --> D{Flux}

    D -- install -->D1{Application}

    D1 --> D1K{Kustomization}

    D1K --> D1HREPO{Helmrepositories}
    D1K --> D1HRELEASE{helmreleases}
    D1K --> PLAIN{Plain Resources}

```

### Operating System

We use Ubuntu 22.04 as our node operating system. Unattended-upgrade for automated security patching is enabled. If necessary, [kured](https://kured.dev/) will manage node reboots.

### Cluster Configuration and Setup

A RKE2 cluster has two types of nodes, a server node with the Kubernetes controlplan and a agent node only with the kubelet.

Our setup is based on the [High Availability](https://docs.rke2.io/install/ha) install instruction:

* RKE2 config files are initially generated with terrafrom and placed in `/etc/rancher/rke2/config.yaml` with cloudinit.
* Token is generated with Terraform (`resource "random_password" "rke2_cluster_secret"`)
* Cilium is used as the CNI Plugin and configured with the `HelmChartConfig` in `/var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml`
* The Kubernetes cluster is kubeproxy free, the functionality is replaced with Cilium. See [Kubernetes Without kube-proxy](https://docs.cilium.io/en/v1.12/gettingstarted/kubeproxy-free/)
* Native Routing is used instead of a tunneling mechanism (e.g. vxlan). The [Kubernetes Cloud Controller Manager for Hetzner Cloud](https://github.com/hetznercloud/hcloud-cloud-controller-manager) is used to manage and provision the network setup (subnet & routing) for the cluster.

#### tl;dr; Provision a Kubernetes Cluster with RKE2

See [Anatomy of a Next Generation Kubernetes Distribution](https://docs.rke2.io/architecture) for more details

1. Provision LoadBalancer for the Kubernetes API and the RKE2 Supervisor
2. Provision first controlplane node.
3. The RKE Supervisor listens on Port 9345/tcp for the other nodes to join the cluster
4. controlplane node 2 & 3 joins the cluster using the same token and they have set `server: https://${lb_address}:9345` in the config file to join the existing cluster.
5. Provision and join the agent nodes using the same token. They also have set `server: https://${lb_address}:9345` to join the existing cluster.

### Flux bootstrap & configuration

Terraform deploys the `GitRepository` resource pointing to this repository and one `Kustomization` resource which will deploy all resources in `deploy/bootstrap`. The `deploy/bootstrap` folder contains more `Kustomization` resources to deploy all our applications. An application can be deployed using plain Kubernetes resource files or from `HelmRepository` with a `HelmRelease`. See [Manage Helm Releases](https://fluxcd.io/flux/guides/helmreleases/) in the flux documentation. Currently most of our applications are deployed using a Helm chart.

## Applications

### Monitoring

The [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) stack is used for monitoring.

The montoring stack is deployed in the `monitoring` namespace.

As the `kube-scheduler`, `kube-controller-manager`, `etcd` only listens on `localhost` on the metrics port, [pushprox](https://github.com/prometheus-community/PushProx) is used to collect the metrics.

### Ingress Controller

The [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) is used with a Hetzner LoadBalancer (automaticly deployed with a Kubernetes service of type `LoadBalancer`and the Hetzner Cloud Controller Manager).

The NGINX Ingress Controller is scaled to 2 replicas and spread on the worker nodes. Proxy Protocol is enabled, `load-balancer.hetzner.cloud/uses-proxyprotocol: true` Annotation on the Service and `use-proxy-protocol: true` in the controller ConfigMap. This allows for real Client-IP's.

### Hetzner CSI

To provision storage we use [Hetzner CSI Driver](https://github.com/hetznercloud/csi-driver).

The StorageClass `hcloud-volumes` is set as default StorageClass

### Sealed Secrets

To keep Secrets safe in our Git Repository we use [sealed secrets](https://sealed-secrets.netlify.app/)

### Rancher System Upgrade Controller

For the Kubernetes Cluster upgrade we use the [Rancher System Upgrade Controller](https://github.com/rancher/system-upgrade-controller) which allows for automated rke2 upgrades.

Two plans are deployed:

* `server-plan` updates the `rke2` binary on the control-plane nodes
* `agent-plan` updates the `rke2` binary on the worker nodes after control-plane nodes are updated

### kured

For safe automated node reboots we use [kured](https://kured.dev/)

When a reboot of a node is requered, `/var/run/reboot-required` is created by `unattended-upgrade`. Kured detects this and will safly reboot the node. Reboots are done everyday between 21:00 and 23:59:59 Europe/Zurich timezone. Befor rebooting, the node gets cordoned and drained and after the reboot uncordoned again. Only one node at the same time is rebooted.

### kyverno

[Kyverno](https://kyverno.io/) is deployed as a policy engine.

### rbac-manager

For easy ServiceAccount and RBAC Management the [rbac-manager](https://rbac-manager.docs.fairwinds.com/) is installed.

## Dependencies

* [Terraform](https://www.terraform.io/)

Check [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) for more details on how to use and install the cli.
  
* [Flux](https://fluxcd.io/)

Check [Flux CLI](https://fluxcd.io/flux/cmd/) for more details on how to use and install the cli.

### Terraform provider & modules

* [Hetzner Cloud Provider](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)
* [kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest)
* [helm](https://registry.terraform.io/providers/hashicorp/helm/latest)
* [tls](https://registry.terraform.io/providers/hashicorp/tls/latest)
* [SSH Terraform Provider](https://registry.terraform.io/providers/loafoe/ssh/latest)

## How to's

## Terraform usage

Login into terraform cloud with your account using:

```bash
terraform login
```

```bash
terraform init -backend-config=backend.hcl # only needed after initial checkout or when you add/change modules
terraform plan # to verify
terraform apply
```

### encrypt a secret

```bash
kubeseal --controller-name sealed-secrets -o yaml < secret.yaml > encrypted-secret.yaml
```

### upgrade Kubernetes version

1. Change version in the System Upgrade Controller plans (`server-plan` & `agent-plan`) in `deploy/system-upgrade-controller/plans/02-plans.yaml`
2. Change the Terraform variable `rke2_version` to match with the newly deployed version.

### Backup sealed-secret controller keys

From [How can I do a backup of my SealedSecrets?](https://github.com/bitnami-labs/sealed-secrets#how-can-i-do-a-backup-of-my-sealedsecrets):

If you do want to make a backup of the encryption private keys, it's easy to do from an account with suitable access:

```bash
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml >main.key
```

To restore from a backup after some disaster, just put that secrets back before starting the controller - or if the controller was already started, replace the newly-created secrets and restart the controller:

```bash
kubectl apply -f main.key
kubectl delete pod -n kube-system -l name=sealed-secrets-controller
```

### Change RKE2 configuration after initial bootstrap

The rke2 configuration is in `/etc/rancher/rke2/config.yaml`. After a change run `systemctl restark rke2-server`. On the agent nodes, run `systemctl restart rke2-agent`.
You have to change the settings on all nodes.

### Change Cilium configuration

The Cilium Helm values are in `/var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml` on the server nodes. You have to change it on all nodes. Afterwards RKE2 automatically reconfigure cilium.
RKE2 uses a cilium version bundled in the [rke2-cilium](https://github.com/rancher/rke2-charts/blob/main/charts/rke2-cilium/rke2-cilium) Helm chart from RKE2. The used version is shown in the [RKE2](https://github.com/rancher/rke2/releases/) release notes.

### Force a manual reconcile of the flux resources

In the current setup, flux does reconcile the resources every 5 minutes. This is configurable on a per resource base. If you want to force the reconcile manualy you can run `flux reconcile source git flux2-sync`. `flux2-sync` is this attached Git Repository and therefore all resources defined will be reconciled. You can also manually reconcile selected resources e.g. `flux reconcile helmrelease -n ingress-nginx ingress-nginx` to only recocile the `ingress-nginx` HelmRelease. See `flux reconcile -h` for all commands.

### Observe network traffic with hubble and the hubble-ui

Hubble is the observability toolof the Cilium CNI. Hubble UI is a WebUI for hubble to observe network flows.

To acess the Hubble UI you have to forward the `hubble-ui` service with:

```bash
kubectl -n kube-system port-forward svc/hubble-ui 8080:80
```

and then you can open http://locahhost:8080 in your browser.

You can also install the hubble cli locally by downloading the correct binary from the [Github Release](https://github.com/cilium/hubble/releases) page.

To use the hubble cli you have to forward the `hubble-relay` service with:

```bash
kubectl -n kube-system port-forward svc/hubble-relay 4245:80
```

and then you can use the `hubble` cli locally. Check `hubble -h` for details on how to use it.
# infrastructure

IaC for acend kubernetes resources

This repo creates the basic acend infrastructure using Terraform.

We use [Hetzner](https://www.hetzner.com/cloud) as our cloud provider and [RKE2](https://docs.rke2.io/) to create the kubernetes cluster.[Kubernetes Cloud Controller Manager for Hetzner Cloud](https://github.com/hetznercloud/hcloud-cloud-controller-manager) to provision lobalancer from a Kubernetes service (type `Loadbalancer`) objects and also configure the networking & native routing for the Kubernetes cluster network traffic.

[ArgoCD](https://argo-cd.readthedocs.io/en/stable/) is used to deploy resourcen on the Kubernetes Cluster

Folder structure:

* `deploy`: Resources for ArgoCD application deployment
* `terraform`: All terraform files for infrastructure deployment

## Workflow

1. Terraform to deploy base infrastructure
   * VM's for controlplane and worker nodes
   * Network
   * Loadbalancer for Kubernetes API and RKE2
   * Firewall
   * Hetzner Cloud Controller Manager for the Kubernetes Cluster Networking
2. Terraform to delploy and bootstrap ArgoCD
3. ArgoCD to deploy resources on the Kubernetes Cluster

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

    A --> D{ArgoCD + Boostrap Application}

    D -- install -->D1{Applications}

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

### ArgoCD bootstrap & configuration

Terraform deploys a ArgoCD `Application` resource pointing to this repository which will deploy all resources from `deploy/bootstrap`. The `deploy/bootstrap` folder contains more ArgoCD `Applications` resources to deploy all our applications. An application can be deployed using plain Kubernetes resource files or from Kustomize, or from Helm Charts. See [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/application_sources/) for details

### Cluster access

For the moment, no external authentication provider is included (see https://github.com/acend/infrastructure/issues/11). We rely on ServiceAccounts and ServiceAccount JWT Tokens to authenticate. RKE2 provides a set of Admin Credentials on intial installation. All other ServiceAccounts and the JWT Tokens are created manually or using the rbac-manager.

See the How to section on how to create a new Service Account with `cluster-admin` permission.

## Applications

### Monitoring

The [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) stack is used for monitoring.

The montoring stack is deployed in the `monitoring` namespace.

As the `kube-scheduler`, `kube-controller-manager`, `etcd` only listens on `localhost` on the metrics port, [pushprox](https://github.com/prometheus-community/PushProx) is used to collect the metrics.

Alertmanager is configured to send alerts to the #ops channel in our Slack workspace.

### Ingress Controller

The [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) is used with a Hetzner LoadBalancer (automaticly deployed with a Kubernetes service of type `LoadBalancer`and the Hetzner Cloud Controller Manager).

The NGINX Ingress Controller is scaled to 2 replicas and spread on the worker nodes. Proxy Protocol is enabled, `load-balancer.hetzner.cloud/uses-proxyprotocol: true` Annotation on the Service and `use-proxy-protocol: true` in the controller ConfigMap. This allows for real Client-IP's.

### Hetzner CSI

To provision storage we use [Hetzner CSI Driver](https://github.com/hetznercloud/csi-driver).

The StorageClass `hcloud-volumes` is set as default StorageClass

### Sealed Secrets

To keep Secrets safe in our Git Repository we use [sealed secrets](https://sealed-secrets.netlify.app/)

For examples on how to use see [How To's / Encrypt a Secret](#encrypt-a-secret)


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
  
* [ArgoCD](https://argo-cd.readthedocs.io/)

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

Examples:

```bash
kubeseal --controller-name sealed-secrets -o yaml < secret.yaml > encrypted-secret.yaml
```

```bash
kubectl -n monitoring create secret generic github-client --from-literal=GF_AUTH_GITHUB_CLIENT_ID="xyz" --from-literal=GF_AUTH_GITHUB_CLIENT_SECRET="xyz" --dry-run=client -o yaml > github-client.yaml
kubeseal --format yaml --controller-name sealed-secrets <github-client.yaml >sealed-github-client.yaml
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

### Create a new ServiceAccount with a JWT Token and `cluster-admin` privileges

Extend the RBACDefinition in `deploy/rbac/cluster-admin.yaml` and add a new `subject` to the `cluster-admin` `roleBindings`. As Kubernetes version >= 1.26 does not automaticly create a ServiceAccount Token (see [Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-an-api-token-for-a-serviceaccount)), you also have to add the `Secret` with the `kubernetes.io/service-account.name` Annotation. Check `deploy/rbac/cluster-admin.yaml` for examples.

Then you need someone who has already access to the cluster to get the Service Account token. You can optain the token and create a kubeconfig file with:

```bash
# executed by someone with Access to the cluster
USERNAME=<username>
IPK8SAPI=<K8S Load Balancer IP or Hostname>
TOKEN=$(kubectl -n rbac-manager get secret $USERNAME -o jsonpath={.data.token} | base64 -d)
kubectl -n rbac-manager get secret $USERNAME -o jsonpath={.data.'ca\.crt'} | base64 -d > ca.crt
export KUBECONFIG=./kubeconfig.yaml
kubectl config set-credentials $USERNAME --token=$TOKEN
kubectl config set-cluster acend-infra --certificate-authority=./ca.crt --embed-certs=true --server https://$IPK8SAPI:6443
kubectl config set-context acend --cluster acend-infra --user $USERNAME
kubectl config use-context acend
cat ./kubeconfig.yaml
```

### Get ArgoCD admin credentials

Run the following command in the `terraform` subfolder to get the `admin` password for ArgoCD:

```bash
terraform output argocd-admin-secret
```

### Get rke2 admin kubeconfig

Run the following command in the `terraform` subfolder to get the kubeconfig file for the admin user created by RKE2:

```bash
terraform output -raw kubeconfig_raw > kubeconfig.yaml
```

### Access Prometheus and Alertmanager UI

Prometheus:

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090
```

and then open [http://localhost:9090](http://localhost:9090)

Alertmanager:

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-alertmanager 9093
```

and then open [http://localhost:9093](http://localhost:9093)

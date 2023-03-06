# Applications

The following applications are deployed:

## ArgoCD

Folder: `terraform/modules/rke2-cluster/argocd.tf`
URL: See Bookmarks in #infrastructure Slack channel

ArgoCD is deployed and then bootstrapped via Terraform.

Login via GitHub OAuth is enabled. User in team `acend/team-cluster-admins` get full access to ArgoCD. There is also a local admin account. See [Get ArgoCD admin Credentials](howto.md#get-argocd-admin-credentials)

## Cert-Manager

Folder: `deploy/cert-manager`

[Cert Manager](https://cert-manager.io/) is used to issue Certificates (Let's Encrypt).
The [ACME Webhook for the hosttech DNS API](https://github.com/piccobit/cert-manager-webhook-hosttech) is used for `dns01` challenges with our DNS provider.

The following `ClusterIssuer` are available:

* `letsencrypt-prod`: for general http01 challenge.
* `letsencrypt-prod-dns01`: for dns01 challenge using the hosttech acme webhook. The token for hosttech is stored in the `hosttech-secret` Secret in Namespace `cert-manager`

Check the [hosttech DNS API](https://api.ns1.hosttech.eu/api/documentation/) for details on how to get a token

All Cert-Manager components are scheduled on the control plane nodes.

## Cluster Autoscaler

Folder: `deploy/cluster-autoscaler`

The [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) with the [Hetzner Provider](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/hetzner/README.md) is used to automaticly scale the Kubernetes Cluster beyond the minimal cluster size of 3 control plane nodes and 2 Worker nodes.

The cluster autoscaler uses the same cloud-init file for the worker node as Terraform does. Terraform created a Secret on the cluster with the cloud init file that is used by the cluster autoscaler.

Currently there is one autoscaling group defined in the cluster autoscaler config (see `deploy/cluster-autoscaler/base/values.yaml`):

```yaml
autoscalingGroups:
  - name: CPX41:NBG1:acend-workerpool1
    maxSize: 2
    minSize: 0
```

This will deploy new nodes whenever needed (when there are `Pending` Pods) and also scales down again when possible. The `CPX41` node type is used and they are deployed in the `nbg1` zone of Hetzner (same as the initially deployed two worker with Terraform).
The two initially deployed worker nodes will never be removed and is part of the minimal cluster size.

For more details on how the Cluster Autoscaler works, see [FAQ](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md).

The cluster autoscaler is scheduled on the control plane nodes.

## Hetzner Kubernetes Cloud Controller Manager

Folder: `terraform/modules/rke2-cluster/ccm.tf`

The [Kubernetes Cloud Controller Manager for Hetzner Cloud](https://github.com/hetznercloud/hcloud-cloud-controller-manager) is deployed and allows to provision LoadBalancer based on Services with type `LoadBalancer`.
The Cloud Controller Manager is also resposible to create all the necessary routes between the Kubernete Nodes. See [Network Support](https://github.com/hetznercloud/hcloud-cloud-controller-manager#networks-support) for details.

## Hetzner CSI

Folder: none, directly from upstream repository

To provision storage we use [Hetzner CSI Driver](https://github.com/hetznercloud/csi-driver).

The StorageClass `hcloud-volumes` is set as default StorageClass.

The hetzner csi provider is scheduled on the control plane nodes.

## Monitoring

Folder: `deploy/kube-prometheus-stack`
Grafana URL: See Bookmarks in #infrastructure Slack channel

The [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) stack is used for monitoring (Prometheus-Operator, Prometheus, Alertmanager, Grafana, Node-Exporter, kube-state-metrics).

The montoring stack is deployed in the `monitoring` namespace.

As the `kube-scheduler`, `kube-controller-manager`, `etcd` only listens on `localhost` on the metrics port, [pushprox](https://github.com/prometheus-community/PushProx) is used to collect the metrics.

Alertmanager is configured to send alerts to the #ops channel in our Slack workspace.

The Grafana-UI is exposed as Ingress. Authentication via GitHub is enabled.

## kubernetes-replicator

Folder: `deploy/kubernetes-replicator`

The [Kubernetes Replicator](https://github.com/mittwald/kubernetes-replicator) is installed to sync Secrets (and ConfigMaps) between namespaces.

Example:

Push a Secret into other Namespaces by Namespace name:

```yaml
apiVersion: v1
kind: Secret
metadata:
  annotations:
    replicator.v1.mittwald.de/replicate-to: "my-ns-1,namespace-[0-9]*"
data:
  key1: <value>
```

Push a Secret into other Namespaces by Labels:

```yaml
apiVersion: v1
kind: Secret
metadata:
  annotations:
    replicator.v1.mittwald.de/replicate-to-matching: >
      my-label=value,my-other-label,my-other-label notin (foo,bar)
data:
  key1: <value>
```

The Kubernetes Replicator is scheduled on the control plane nodes.

## kured

Folder: `deploy/kured`

For safe automated node reboots we use [kured](https://kured.dev/)

When a reboot of a node is requered, `/var/run/reboot-required` is created by `unattended-upgrade`. Kured detects this and will safly reboot the node. Reboots are done everyday between 21:00 and 23:59:59 Europe/Zurich timezone. Befor rebooting, the node gets cordoned and drained and after the reboot uncordoned again. Only one node at the same time is rebooted.

## Logging

Folder: `deploy/loki` & `deploy/promtail`

[Loki](https://grafana.com/oss/loki/) and [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/) are in use for Container Logs.

Logs are kept 31 days.

Within Grafana / Explore you have access to the container logs.

The storage backend is set to the local Minio S3 installation.

## Minio S3

Folder: `deploy/minio`

The [minio operator](https://github.com/minio/operator) is deployed to create a S3 service.

Access to the Minio is Console: https://minio-console.<cluster-domain> with the JWT Token in the secret `console-sa-secret`

There is a Minio Tenant deployed with name `acend-s3` in the `acend-s3` Namespace. The Minio operator creates the Minio S3 instance.

### acend-s3 Tenant

URL: https://s3.<cluster-domain>
Console: https://s3-console.<cluster-domain>

Credentials for console access in Secret `acend-s3-env-configuration` in Namespace `acend-s3`. S3 Access and Secret Keys can be generated in the S3 Console of the acend-s3 tenant.

For Tenant configuration see `deploy/minio/base/values-tenant.yaml`.

## kyverno

Folder: `deploy/kyverno`

[Kyverno](https://kyverno.io/) is deployed as a policy engine.

Kyverno is scheduled on the control plane nodes.

## NGINX Ingress Controller

Folder: `deploy/nginx-ingress-controller`

The [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) is used with a Hetzner LoadBalancer (automaticly deployed with a Kubernetes service of type `LoadBalancer`and the Hetzner Cloud Controller Manager).

The NGINX Ingress Controller is scaled to 2 replicas and spread on the worker nodes. Proxy Protocol is enabled, `load-balancer.hetzner.cloud/uses-proxyprotocol: true` Annotation on the Service and `use-proxy-protocol: true` in the controller ConfigMap. This allows for real Client-IP's.

## rbac-manager

Folder: `deploy/rbac-manager` & `deploy/rbac`

For easy ServiceAccount and RBAC Management the [rbac-manager](https://rbac-manager.docs.fairwinds.com/) is installed.

The RBAC manager scheduled on the control plane nodes.

## Sealed Secrets

Folder: `deploy/csealed-secrets`

To keep Secrets safe in our Git Repository we use [sealed secrets](https://sealed-secrets.netlify.app/)

For examples on how to use see [How To's / Encrypt a Secret](howto.md#encrypt-a-secret)

Sealed Secrets is scheduled on the control plane nodes.

## System Upgrade Controller

Folder: `deploy/system-upgrade-controller`

For the Kubernetes Cluster upgrade we use the [Rancher System Upgrade Controller](https://github.com/rancher/system-upgrade-controller) which allows for automated rke2 upgrades.

Two plans are deployed:

* `server-plan` updates the `rke2` binary on the control-plane nodes
* `agent-plan` updates the `rke2` binary on the worker nodes after control-plane nodes are updated

The System Upgrade Controller is scheduled on the control plane nodes.

## Velero

Folder: `deploy/velero`

[Velero](https://velero.io/) is deployed for Kubernetes manifest backup.
There is a `full-back` Schedule everynight at 02:00

For the moment, the backupstoragelocation is set to the local Minio S3 installation.

## Acend configuration

Folder: `deploy/acend`

For the acend related resources there is an `acend` ArgoCD Application. The application does:

* Deploy acend Namespaces (in which Github can deploy resources)
* Acend Certificates (e.g. our `*.training.acend.ch` wildcard certificate shared in all `acend-*` Namespaces)

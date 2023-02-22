# How to's

## Terraform usage

Login into Terraform cloud with your account using:

```bash
terraform login
```

```bash
terraform init -backend-config=backend.hcl # only needed after initial checkout or when you add/change modules
terraform plan # to verify
```

As we use Terraform cloud, a `terraform apply` cannot be executed locally. You have to commit/push your changes and then let Terraform cloud execute the run.

## encrypt a secret

Examples:

```bash
kubeseal --controller-name sealed-secrets -o yaml < secret.yaml > encrypted-secret.yaml
```

```bash
kubectl -n monitoring create secret generic github-client --from-literal=GF_AUTH_GITHUB_CLIENT_ID="xyz" --from-literal=GF_AUTH_GITHUB_CLIENT_SECRET="xyz" --dry-run=client -o yaml > github-client.yaml
kubeseal --format yaml --controller-name sealed-secrets <github-client.yaml >sealed-github-client.yaml
```

## upgrade Kubernetes version

1. Change version in the System Upgrade Controller plans (`server-plan` & `agent-plan`) in `deploy/system-upgrade-controller/base/plans.yaml`
2. Change the Terraform variable `rke2_version` to match with the newly deployed version.

## Backup sealed-secret controller keys

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

## Change RKE2 configuration after initial bootstrap

The rke2 configuration is in `/etc/rancher/rke2/config.yaml` and was initially generated with terraform and deployed using cloud-init. Terraform does not change this anymore after initial node setup. Therefore you have to manually change (or recreate the node). After a change run `systemctl restark rke2-server`. On the agent nodes, run `systemctl restart rke2-agent`. You have to change the settings on all nodes.

## Change Cilium configuration

The Cilium Helm values are in `/var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml` on the server nodes. You have to change it on all nodes. Afterwards RKE2 automatically reconfigure cilium.
RKE2 uses a Cilium version bundled in the [rke2-cilium](https://github.com/rancher/rke2-charts/blob/main/charts/rke2-cilium/rke2-cilium) Helm chart from RKE2. The used version is shown in the [RKE2](https://github.com/rancher/rke2/releases/) release notes.

## Observe network traffic with hubble and the hubble-ui

Hubble is the observability toolof the Cilium CNI. Hubble UI is a WebUI for hubble to observe network flows.

To acess the Hubble UI you have to forward the `hubble-ui` service with:

```bash
kubectl -n kube-system port-forward svc/hubble-ui 8080:80
```

and then you can open [http://locahhost:8080](http://locahhost:8080) in your browser.

You can also install the hubble cli locally by downloading the correct binary from the [Github Release](https://github.com/cilium/hubble/releases) page.

To use the hubble cli you have to forward the `hubble-relay` service with:

```bash
kubectl -n kube-system port-forward svc/hubble-relay 4245:80
```

and then you can use the `hubble` cli locally. Check `hubble -h` for details on how to use it.

## Create a new ServiceAccount with a JWT Token and `cluster-admin` privileges

Extend the RBACDefinition in `deploy/rbac/cluster-admin.yaml` and add a new `subject` to the `cluster-admin` `roleBindings`. As Kubernetes version >= 1.26 does not automaticly create a ServiceAccount Token (see [Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-an-api-token-for-a-serviceaccount)), you also have to add the `Secret` with the `kubernetes.io/service-account.name` Annotation. Check `deploy/rbac/cluster-admin.yaml` for examples.

Then you need someone who has already access to the cluster to get the Service Account token. You can obtain the token and create a kubeconfig file with:

```bash
# executed by someone with Access to the cluster
SA=<username>
IPK8SAPI=<K8S Load Balancer IP or Hostname>
TOKEN=$(kubectl -n rbac-manager get secret $SA -o jsonpath={.data.token} | base64 -d)
kubectl -n rbac-manager get secret $SA -o jsonpath={.data.'ca\.crt'} | base64 -d > ca.crt
export KUBECONFIG=./kubeconfig.yaml
kubectl config set-credentials $SA --token=$TOKEN
kubectl config set-cluster acend-infra --certificate-authority=./ca.crt --embed-certs=true --server https://$IPK8SAPI:6443
kubectl config set-context acend --cluster acend-infra --user $SA
kubectl config use-context acend
unset KUBECONFIG
cat ./kubeconfig.yaml
```

## Get ArgoCD admin credentials

Run the following command in the `terraform` subfolder to get the `admin` password for ArgoCD:

```bash
terraform output argocd-admin-secret
```

or directly via Kubernetes Secret:

```bash
kubectl -n argocd get secrets/argocd-initial-admin-secret --template={{.data.password}} | base64 -d
```

## Get rke2 admin kubeconfig

Run the following command in the `terraform` subfolder to get the kubeconfig file for the admin user created by RKE2:

```bash
terraform output -raw kubeconfig_raw > kubeconfig.yaml
```

## Access Prometheus and Alertmanager UI

The Prometheus and Alertmanager UI are not exposed via Ingress Resource. You have to port-forward the services and access it via `localhost`.

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

## Locally generate Application Manifest Files

As we use kustomize, you can simple execute e.g.:

```bash
kustomize build --enable-helm ./deploy/acend/base
```

# Troubleshooting

## Kubeconfig not valid anymore

The ServiceAccount Token might have changed due to Certificate Rotation of RKE2. You have to get a new Token.

## Access ArgoCD when no ingress controller is available

In case where no ingress controller is available, you can still access ArgoCD using a port-forward:

```bash
kubectl -n argocd port-forward svc/argocd-server 8443:443
```

and then you can use the `argocd` cli with and the admin credentials:

```bash
argocd login localhost:8443
```

## Recreate Nodes

1. Delete the node from Kubernetes with `kubectl delete node <nodename>
2. Delete the vm from Hetzner cloud
3. Let Terraform recreate the VM'

**warning**: Don't remove all controlplane together. Do it one by one.

## No connection between Pods on different nodes

We use the [Hetzner Cloud Controller Manager](applications.md#hetzner-kubernetes-cloud-controller-manager) to setup nativ routing for the cluster network.

* Check if CCM is up and running and you don't see any errors in the log
* Check the Hetzner Cloud Console. Go to Networks -> `prod` -> Routes and make sure you see the Kubernetes Cluster Network Routes from range `10.244.0.0/16`. There should be one `/24` route for each of the Kubernetes nodes.

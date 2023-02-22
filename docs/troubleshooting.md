# Troubleshooting

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

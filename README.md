# k8s-homelab

> **Status: under construction.** The skeleton and docs exist, but
> no cluster has been provisioned yet and the manifests are not finished. Do not
> rely on this repository as a working deployment yet.

Reproducible Kubernetes homelab that runs on **one machine or N machines** from the same codebase, managed declaratively, and usable as a study lab for **CKA / CKAD / CKS**.

- **Kubernetes:** upstream via `kubeadm` (containerd runtime), pinned to a supported minor version.
- **Desired state:** GitOps with Argo CD (app-of-apps + ApplicationSets).
- **Provisioning:** Ansible (idempotent) for hosts and cluster bring-up.
- **Maintenance:** Renovate PRs, Argo CD auto-sync/self-heal, documented runbooks.

## Repository layout

```text
ansible/    host + cluster provisioning (inventory per topology)
bootstrap/  one-time: CNI, Argo CD, root Application
gitops/     everything Argo CD reconciles
docs/       architecture, roadmap, runbooks, certification map
.ai/        portable agent context (source of truth: AGENTS.md)
```

## Components

Argo CD reconciles `gitops/`. Each component is a directory rendered with
kustomize `helmCharts` (`--enable-helm`). Chart versions are pinned.

| Layer | Component | Version |
| --- | --- | --- |
| infrastructure | MetalLB (+ LAN address pool) | 0.16.1 |
| infrastructure | cert-manager (+ self-signed ClusterIssuer) | v1.21.2 |
| infrastructure | ingress-nginx | 4.15.1 |
| infrastructure | local-path-provisioner (default StorageClass) | v0.0.37 |
| platform | metrics-server | 3.14.0 |
| platform | kube-prometheus-stack | 91.4.0 |

Pending: internal DNS, Longhorn (needs >=3 nodes), Loki, Velero, secret
management (ADR-008). See the `README.md` in each layer.

## Quickstart (once hosts exist)

```bash
# 1. Prepare hosts and build the cluster
ansible-playbook -i ansible/inventory/lab.ini ansible/playbooks/prepare.yml
ansible-playbook -i ansible/inventory/lab.ini ansible/playbooks/cluster-init.yml

# 2. Bootstrap CNI + Argo CD, then let GitOps take over
GITOPS_REPO_URL=https://github.com/crilsen/k8s-homelab.git ./bootstrap/install.sh

# 3. Verify
kubectl get nodes
kubectl -n argocd get applications
```

See `docs/bootstrap.md` for details and `docs/roadmap.md` for the phased plan.

## Status

The code (Ansible + GitOps manifests + docs) is in place, but **nothing has been
run against a cluster**: it is not validated end to end. No cluster exists yet
(the two target hosts are not up). The MetalLB pool and addresses are set for the
`192.168.0.0/24` LAN; adjust if your network differs.

## Open items

- Internal domain (default `lab.local`) and LAN DNS approach.
- Secret-management mechanism (ADR-008).
- Validation against real hardware.

# k8s-homelab

> **Status: em construção (pre-deployment).** The code and manifests are written
> and version-pinned, but nothing has been applied or validated against a real
> cluster yet. The two target hosts are not up.

Reproducible Kubernetes homelab that runs on **one machine or N machines** from the same codebase, managed declaratively, and usable as a study lab for **CKA / CKAD / CKS**.

- **Kubernetes:** upstream via `kubeadm` (containerd runtime), pinned to a supported minor version.
- **Desired state:** GitOps with Argo CD (app-of-apps + ApplicationSets).
- **Provisioning:** Ansible (idempotent) for hosts and cluster bring-up.
- **Maintenance:** Renovate PRs, Argo CD auto-sync/self-heal, documented runbooks.

## What's ready

Argo CD reconciles `gitops/`; each component is a directory rendered with
kustomize `helmCharts` (`--enable-helm`). Chart versions are pinned.

| Layer | Component | Version | Purpose |
| --- | --- | --- | --- |
| infrastructure | MetalLB (+ LAN address pool) | 0.16.1 | `LoadBalancer` IPs on bare metal |
| infrastructure | cert-manager (+ self-signed ClusterIssuer) | v1.21.2 | TLS certificates |
| infrastructure | ingress-nginx | 4.15.1 | default IngressClass |
| infrastructure | local-path-provisioner | v0.0.37 | default `StorageClass` |
| platform | metrics-server | 3.14.0 | `kubectl top`, HPA |
| platform | kube-prometheus-stack | 91.4.0 | Prometheus + Grafana + Alertmanager |

Also ready: Ansible provisioning (`ansible/`), the one-time bootstrap
(`bootstrap/`), and the runbooks (`docs/runbooks/`).

## Not included yet

Internal DNS, Longhorn (needs >=3 nodes for a healthy replica count), Loki,
Velero, and secret management (see `.ai/DECISIONS.md`, ADR-008). See the
`README.md` inside each layer under `gitops/`.

## Repository layout

```text
ansible/    host + cluster provisioning (inventory per topology)
bootstrap/  one-time: CNI, Argo CD, root Application
gitops/     everything Argo CD reconciles
docs/       architecture, roadmap, runbooks, certification map
.ai/        portable agent context (source of truth: AGENTS.md)
```

## Target topology

Two nodes on `192.168.0.0/24`: 1 control plane (`192.168.0.201`) + 1 worker
(`192.168.0.202`). A single-node inventory (`single-node.ini`) is also included.
Pod/service CIDRs are `10.244.0.0/16` and `10.96.0.0/12`; MetalLB pool is
`192.168.0.240-192.168.0.250`. Adjust these in `ansible/group_vars/`,
`ansible/inventory/`, and the matching `gitops/infrastructure/metallb/` pool if
your LAN differs.

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

## Validation status

- YAML parse of all manifests: validated.
- `kubectl kustomize gitops/infrastructure/local-path`: validated.
- Helm-based components and the full Ansible flow: **not validated** (no
  cluster available yet).

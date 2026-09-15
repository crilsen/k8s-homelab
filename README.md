# k8s-homelab

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

## Quickstart (once hosts exist)

```bash
# 1. Prepare hosts and build the cluster
ansible-playbook -i ansible/inventory/single-node.ini ansible/playbooks/prepare.yml
ansible-playbook -i ansible/inventory/single-node.ini ansible/playbooks/cluster-init.yml

# 2. Bootstrap CNI + Argo CD, then let GitOps take over
./bootstrap/install.sh

# 3. Verify
kubectl get nodes
kubectl -n argocd get applications
```

See `docs/bootstrap.md` for details and `docs/roadmap.md` for the phased plan.

## Status

Skeleton and documentation only. No cluster has been provisioned yet. This directory is not yet a Git repository.

## Assumptions to confirm before first build

- Host inventory (addresses, users, SSH keys).
- Internal domain and MetalLB address pool.
- Whether the first build enables an HA control plane (3 nodes + API VIP).
- Secret-management mechanism (see `.ai/DECISIONS.md`, ADR-008).

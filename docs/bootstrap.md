# Bootstrap

One-time bring-up from bare hosts to a GitOps-managed cluster.

## Prerequisites

- Ubuntu hosts reachable over SSH (VM and/or bare-metal), with sudo.
- Ansible on the control machine; `ansible-galaxy collection install -r ansible/requirements.yml`.
- `kubectl` on the control machine.
- The repository reachable from the cluster (Argo CD pulls it). Replace `<YOUR_ORG>` in `gitops/` and `bootstrap/` first.

## Steps

### 1. Prepare every node

```bash
ansible-playbook -i ansible/inventory/single-node.ini ansible/playbooks/prepare.yml
```

Installs the runtime and the pinned kubelet/kubeadm/kubectl. Idempotent.

### 2. Build the cluster

```bash
ansible-playbook -i ansible/inventory/single-node.ini ansible/playbooks/cluster-init.yml
```

Initializes the first control plane, joins the remaining control-plane nodes
(lab inventory), then the workers. The cluster is up but **NotReady** (no CNI).

### 3. Bootstrap CNI + Argo CD + root app

```bash
GITOPS_REPO_URL=https://github.com/<your-org>/k8s-homelab.git ./bootstrap/install.sh
```

Applies the CNI, installs Argo CD, and applies the root Application. Argo CD then
reconciles `gitops/` (infrastructure → platform → workloads).

### 4. Verify

```bash
kubectl get nodes -o wide
kubectl -n argocd get applications
kubectl -n argocd get app root -o jsonpath='{.status.sync.status}{"\n"}'
```

## Notes

- The cluster is not considered "done" until the CNI is applied.
- Keep versions pinned in `ansible/group_vars/all/main.yml`; do not use `latest`.
- `control_plane_endpoint` must resolve to the first control-plane address
  (single-node) or the kube-vip VIP (HA).

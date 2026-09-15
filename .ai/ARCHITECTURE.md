# Architecture

## Status

Designed, not yet built. Everything below is **recommended** unless marked **observed**.

## Observed

- Repository contains only the portable context (`.ai/`, `AGENTS.md`) plus this skeleton; no cluster exists.

## Target architecture (recommended)

```text
Hosts (Ubuntu, mixed VM + bare-metal)
        │  Ansible: base + containerd + kubeadm/kubelet/kubectl
        ▼
Kubernetes upstream (kubeadm), pinned minor version
   control-plane(s) ── etcd (stacked) ── kube-vip (API VIP, HA)
   workers          ── CNI: Calico
        │  bootstrap: apply CNI → install Argo CD → apply root-app
        ▼
GitOps (Argo CD, app-of-apps + ApplicationSets)
   infrastructure → MetalLB, ingress-nginx, cert-manager, storage, DNS
   platform       → metrics-server, kube-prometheus-stack, Loki, Velero
   workloads      → user applications
```

## Component choices (recommended)

| Layer | Choice | Rationale |
| --- | --- | --- |
| Kubernetes | **kubeadm**, upstream 1.37 (supported: 1.37/1.36/1.35) | Prod fidelity + required by CKA/CKAD/CKS |
| Runtime | containerd + SystemdCgroup | Standard on kubeadm/exams |
| CNI | Calico | Prod-common; exercises NetworkPolicy for CKS |
| Load balancer | MetalLB (L2) | Real LAN IPs on bare metal/VM |
| Ingress | ingress-nginx | Most common; cert-relevant |
| TLS | cert-manager | Internal CA or Let's Encrypt DNS-01 |
| Storage (1 node) | local-path-provisioner | Simplest dynamic PVCs |
| Storage (N nodes) | Longhorn | Replicated PVCs, snapshots |
| GitOps | Argo CD | Declarative sync, prune, self-heal |
| Secrets | TBD (SOPS+age / Sealed Secrets / ESO+Vault) | Deferred decision |
| Observability | kube-prometheus-stack + Loki | Standard stack |
| Backup/DR | Velero + etcd snapshots | Cluster + volume restore |
| Dependency updates | Renovate | Automated, reviewed PRs |

## Scaling model

Same manifests; only the per-cluster overlay differs.

| Scenario | Nodes | Control plane | Storage | Notes |
| --- | --- | --- | --- | --- |
| dev/lab | 1 | 1 | local-path | Single point of failure accepted |
| home | 3 | 1 (+2 workers) | Longhorn | Apps survive node loss |
| HA | 3–5 | 3 (stacked etcd) + kube-vip VIP | Longhorn | Survives one control-plane loss |

## Bootstrap ordering

1. Ansible provisions hosts and runs `kubeadm init` / `join`. Cluster is up but `NotReady` (no CNI).
2. `bootstrap/` applies the CNI, installs Argo CD, and applies the root Application.
3. Argo CD reconciles `gitops/` (infrastructure → platform → workloads) using sync waves.

## Context layer

`.ai/` is the portable source of truth; `AGENTS.md` routes to it. Tool-specific files, if added, are thin adapters only.

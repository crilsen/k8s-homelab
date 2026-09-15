# Architecture

This document is the human-facing overview. The machine-oriented context lives in `.ai/ARCHITECTURE.md` and `.ai/DECISIONS.md`; keep the two consistent.

## Layers

```text
Hosts (Ubuntu, VM + bare-metal)
   │  Ansible: common → container_runtime → kube_packages
   ▼
Kubernetes (kubeadm, containerd)
   │  playbooks: cluster-init / join
   ▼
Bootstrap (one-time)
   │  CNI → Argo CD → root Application
   ▼
GitOps (Argo CD, continuous)
   infrastructure → platform → workloads
```

## Why kubeadm

The homelab doubles as a certification lab (CKA/CKAD/CKS) and should resemble
self-managed production. kubeadm exposes the control plane, etcd, certificates,
and upgrade mechanics the exams require; lightweight distributions hide them.

## Scaling

One inventory per topology; one GitOps tree; per-cluster overlays.

| Scenario | Nodes | Control plane | Storage |
| --- | --- | --- | --- |
| single-node | 1 | 1 | local-path |
| lab | 3–5 | 3 (stacked etcd) + kube-vip VIP | Longhorn |

Adding a node is a data change: add a host to the inventory, run
`playbooks/prepare.yml` then `playbooks/join.yml`.

## Failure and recovery

- etcd: scheduled snapshots + documented restore (`docs/runbooks/restore-etcd.md`).
- Workloads and volumes: Velero backups with a periodic restore drill.
- Desired state: Git. Reverting a bad change is `git revert` + Argo sync.

## Open items

- Secret management (ADR-008).
- Whether the first build enables the HA control plane.
- Concrete addresses, domain, and MetalLB pool.

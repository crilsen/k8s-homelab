# Project

## Identity

- **Name:** k8s-homelab
- **Objective:** A reproducible, declaratively managed Kubernetes homelab that runs on a single machine or on N machines with the same codebase, and doubles as a study lab for Kubernetes certifications (CKA, CKAD, CKS).
- **Repository purpose:** Hold host provisioning (Ansible), upstream Kubernetes bootstrap (kubeadm), and GitOps desired state (Argo CD), plus runbooks.
- **Status:** Adopted. Fase 0 done and published. Fase 2 baseline + observability components are written and version-pinned, but nothing has been applied or validated against a cluster (no hosts yet).

## Observed

- At adoption time the directory contained only `AGENTS.md` and `.ai/` (plus a stray `.DS_Store`); there was no application or infrastructure code.
- The directory is **not** a Git repository (no `.git` in it or in any parent). No branch, remote, or commit history exists.
- No `.gitignore` or `README.md` existed (the template docs referenced them, but they were absent).

## Design intent

- **Production fidelity and certification value over convenience:** use upstream `kubeadm`, not k3s, because the exams and most self-managed production clusters are built on it.
- **One codebase, 1..N nodes:** node count, addresses, domain, and storage class are variables per cluster overlay, not forks.
- **Declarative everything:** the Git repository is the source of truth; no manual cluster edits.
- **Maintainability:** Ansible for idempotent host/cluster operations, Argo CD for continuous reconciliation, Renovate for dependency bumps, runbooks for routine operations.

## Non-goals (for now)

- A managed-cloud equivalent; this is bare-metal/VM homelab.
- Multi-tenant or production SLA guarantees.

## Open decisions

- Secret management for GitOps (SOPS+age vs Sealed Secrets vs External Secrets+Vault) — deferred.
- Concrete host inventory, IPs, and internal domain — pending.
- Whether to enable an HA control plane (3 nodes + API VIP) in the first build.

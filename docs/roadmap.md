# Roadmap

Phased plan. Each phase has a deliverable and acceptance criteria. Do not start a
phase until the previous one is accepted.

## Fase 0 — Foundation (this change)

- Adopt the portable context in `.ai/` with real facts.
- Create the repository skeleton: `ansible/`, `bootstrap/`, `gitops/`, `docs/`.
- **Acceptance:** structure present and documented; no secrets committed. *(Done, pending `git init`.)*

## Fase 1 — Nodes

- Confirm inventory (addresses, user, SSH key).
- Run `prepare.yml` and `cluster-init.yml`.
- **Acceptance:** `kubectl get nodes` shows all nodes `Ready` (after CNI) on both single-node and lab inventories.

## Fase 2 — Baseline

- MetalLB (L2 pool), ingress-nginx, cert-manager, storage class, internal DNS.
- Manifests for MetalLB, ingress-nginx, cert-manager and local-path are **written
  and pinned** (`gitops/infrastructure/`), but not yet applied or validated.
- Remaining: internal DNS component.
- **Acceptance:** a test app is reachable over HTTPS at `app.<domain>` via a MetalLB address.

## Fase 3 — GitOps

- Argo CD root Application, ApplicationSets per layer, Renovate.
- Decide and implement secret management (ADR-008).
- **Acceptance:** a commit under `gitops/` is reflected in the cluster; root app `Synced`/`Healthy`; no `OutOfSync`.

## Fase 4 — Platform

- metrics-server, kube-prometheus-stack + Loki, Velero + etcd snapshots.
- metrics-server and kube-prometheus-stack manifests are **written and pinned**
  (`gitops/platform/`). Loki and Velero remain to be added.
- **Acceptance:** cluster/node dashboards; a scheduled backup and a **tested restore**.

## Fase 5 — Workloads

- First real applications, 100% via GitOps.
- **Acceptance:** at least one app with ingress, TLS, PVC, probes, and resource limits.

## Fase 6 — Operations

- Runbooks: add-node, upgrade, etcd restore, break-glass.
- **Acceptance:** each runbook exercised at least once.

## Certification track

See `docs/certification-track.md` for the mapping from phases to CKA/CKAD/CKS topics.

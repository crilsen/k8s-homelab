# Session Handoff

## Resume block (read first)

- Repo state: branch `dev`, tracking `origin/dev` (`https://github.com/crilsen/k8s-homelab`, public). Working tree clean.
- Source of truth: `AGENTS.md` → `.ai/`
- Budget / usage observed: unknown
- Checkpoint updated: 2026-09-15
- Last goal: Fase 0 — adopt the context, create the skeleton + docs, and publish the repo.
- Exact next action: start Fase 1. Confirm the inventory (IPs, SSH user/key), internal domain, MetalLB pool, and whether the first build is HA; replace the placeholder addresses in `ansible/inventory/*.ini`, then run `prepare.yml` and `cluster-init.yml`.
- Blocked by: inventory/domain/MetalLB values unknown; secret-management decision deferred (ADR-008).
- Resume prompt: `Read AGENTS.md and .ai/HANDOFF.md. Continue from the Resume block. Do not rediscover context.`

## Goal

A reproducible Kubernetes homelab (kubeadm) that runs on one or N machines from
one codebase, is maintained declaratively, and doubles as a CKA/CKAD/CKS lab.

## Current State

Fase 0 complete: the `.ai/` context is adopted with real facts, the repo skeleton
exists (`ansible/`, `bootstrap/`, `gitops/`, `docs/`, `README.md`, `.gitignore`),
and it is published at `github.com/crilsen/k8s-homelab` (branch `dev`). No
cluster is provisioned and no hosts are configured.

## What Was Done

- Decided architecture: kubeadm + containerd, Calico, MetalLB, ingress-nginx,
  cert-manager, storage (local-path/Longhorn), Argo CD GitOps, Renovate.
- Recorded decisions ADR-004..ADR-008.
- Created Ansible inventory/group_vars/playbooks/roles for prepare, cluster-init,
  join, and a guarded upgrade placeholder.
- Created `bootstrap/install.sh` (CNI → Argo CD → root app) and `bootstrap/root-app.yaml`.
- Created GitOps skeleton: ApplicationSets per layer, per-cluster overlays.
- Wrote docs: architecture, roadmap, bootstrap, runbooks, certification track.

## Files Changed

- `README.md`, `.gitignore` (new)
- `.ai/PROJECT.md`, `ARCHITECTURE.md`, `CONVENTIONS.md`, `DECISIONS.md`, `TOOLS.md`, `VALIDATION.md`, `TASKS.md`, `HANDOFF.md`
- `ansible/` (new): `ansible.cfg`, `requirements.yml`, `inventory/{single-node,lab}.ini`, `group_vars/all/main.yml`, `playbooks/{prepare,cluster-init,join,upgrade}.yml`, `roles/{common,container_runtime,kube_packages,kubeadm_control_plane,kubeadm_join}`
- `bootstrap/` (new): `install.sh`, `root-app.yaml`
- `gitops/` (new): `README.md`, `apps/appsets.yaml`, `clusters/{single-node,lab}/config.yaml`, layer READMEs
- `docs/` (new): `architecture.md`, `roadmap.md`, `bootstrap.md`, `certification-track.md`, `runbooks/{add-node,upgrade-cluster,restore-etcd,break-glass}.md`

## Decisions Made

- ADR-004 kubeadm over k3s (prod fidelity + certification).
- ADR-005 one codebase for 1..N nodes via overlays.
- ADR-006 Argo CD as system of record after bootstrap.
- ADR-007 baseline component choices.
- ADR-008 secret management deferred.

## Problems / Risks

- Version pins (`kubernetes_package_version`, Calico version, pause image) must be
  verified against the current repositories before the first real run.
- kube-vip / HA control-plane endpoint is documented but not implemented in the roles.
- The ApplicationSets contain a `<YOUR_ORG>` placeholder that must be replaced once
  the remote exists.
- Nothing is validated against real hosts/cluster; `yamllint`/`ansible-lint`/`shellcheck` not run (not installed).

## Validation Performed

- `ansible-playbook --syntax-check` on all four playbooks: **Validated** (with
  `community.general`, `ansible.posix`, `kubernetes.core` installed).
- Inventory topology patterns (`k8s_control_plane[0]`, `[1:]`, workers):
  **Validated** for both `single-node.ini` (1/0/0) and `lab.ini` (1/2/2).
- YAML parse of all `*.yml`/`*.yaml`: **Validated**.
- `bash -n bootstrap/install.sh`: **Validated**.
- `yamllint`, `ansible-lint`, `shellcheck`: **Not validated** (not installed).

## Next Actions

- `git init`, add remote, commit Fase 0.
- Run `yamllint` and `ansible-lint`; fix findings.
- Confirm inventory/domain/MetalLB/HA decisions; replace `<YOUR_ORG>`.
- Proceed to Fase 1 (nodes).

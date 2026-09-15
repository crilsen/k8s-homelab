# Session Handoff

## Resume block (read first)

- Repo state: branch `dev`, tracking `origin/dev` (`https://github.com/crilsen/k8s-homelab`, public). Working tree clean.
- Source of truth: `AGENTS.md` → `.ai/`
- Budget / usage observed: unknown
- Checkpoint updated: 2026-09-15
- Last goal: write the ready-to-apply GitOps components (Fase 2 baseline + observability).
- Exact next action: once `192.168.0.201/.202` are reachable over SSH, run `ansible-playbook -i ansible/inventory/lab.ini ansible/playbooks/prepare.yml --check`, then without `--check`, then `cluster-init.yml`, then `GITOPS_REPO_URL=https://github.com/crilsen/k8s-homelab.git ./bootstrap/install.sh`, then watch the Applications sync.
- Blocked by: hosts unreachable (no ICMP, port 22 closed on 192.168.0.201/.202 as of 2026-09-15). Internal domain and secret management (ADR-008) still open.
- Resume prompt: `Read AGENTS.md and .ai/HANDOFF.md. Continue from the Resume block. Do not rediscover context.`

## Goal

A reproducible Kubernetes homelab (kubeadm) that runs on one or N machines from
one codebase, is maintained declaratively, and doubles as a CKA/CKAD/CKS lab.

## Current State

Fase 0 complete and published at `github.com/crilsen/k8s-homelab` (branch `dev`).
Fase 1 inventory confirmed: two-node topology (1 control plane `192.168.0.201`,
1 worker `192.168.0.202`, `.203` reserved), Ubuntu with user `ubuntu` and key
`~/.ssh/id_ed25519`, pod/service `10.244.0.0/16` / `10.96.0.0/12`, MetalLB
`192.168.0.240-192.168.0.250`, storage `local-path`. The hosts are **not
reachable yet**, so nothing has been provisioned or validated against them.

## What Was Done (latest)

- Implemented the Fase 2 baseline components and two platform components as
  pinned kustomize `helmCharts` directories: `metallb` (+ `addresspool.yaml`),
  `cert-manager` (+ self-signed `ClusterIssuer`), `ingress-nginx`, `local-path`
  (vendored v0.0.37 + default StorageClass patch), `metrics-server`, and
  `kube-prometheus-stack`. ApplicationSets now pass
  `kustomize.buildOptions: --enable-helm` (ADR-010).
- Validated: YAML parse of all files; `kubectl kustomize` build of `local-path`
  (patch applied correctly). Helm-based components are **not** built (no helm),
  and nothing was applied to a cluster.

## What Was Done (initial Fase 0)

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
- YAML parse of all `*.yml`/`*.yaml` (incl. vendored `local-path/manifest.yaml`): **Validated**.
- `kubectl kustomize gitops/infrastructure/local-path`: **Validated** (9 objects; default-class annotation applied).
- Helm-based components (metallb, cert-manager, ingress-nginx, metrics-server, kube-prometheus-stack): kustomize `--enable-helm` build **Not validated** (no `helm` locally).
- `bash -n bootstrap/install.sh`: **Validated**.
- `yamllint`, `ansible-lint`, `shellcheck`: **Not validated** (not installed).

## Next Actions

- `git init`, add remote, commit Fase 0.
- Run `yamllint` and `ansible-lint`; fix findings.
- Confirm inventory/domain/MetalLB/HA decisions; replace `<YOUR_ORG>`.
- Proceed to Fase 1 (nodes).

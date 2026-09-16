# Current Work

## Active

- Fase 1 (nodes): topology confirmed (1 CP `192.168.0.201` + 1 worker `192.168.0.202`, Ubuntu, user `ubuntu`, key `~/.ssh/id_ed25519`). **Blocked:** both hosts are unreachable (no ICMP, port 22 closed) as of 2026-09-15; nothing provisioned yet.

## Planned

- Fase 1 — provision nodes: confirm inventory, run `prepare.yml` + `cluster-init.yml`.
- Fase 2 — baseline: MetalLB, ingress-nginx, cert-manager, storage, DNS.
- Fase 3 — GitOps: Argo CD root app + ApplicationSets, decide secret management (ADR-008).

## Blocked

- Hosts `192.168.0.201/.202` are not reachable (not powered on / not created yet).
- Internal domain (default `lab.local`) and secret-management mechanism (ADR-008) still open.

## Completed

- Adopted the portable context with real facts (PROJECT, ARCHITECTURE, CONVENTIONS, DECISIONS, TOOLS, VALIDATION).
- Created the repository skeleton: `ansible/` (inventory, group_vars, playbooks, roles), `bootstrap/`, `gitops/` (apps, layers, clusters), `docs/`.
- Documented architecture, roadmap, bootstrap, runbooks (add-node, upgrade, restore-etcd, break-glass), and certification track.
- Initialized Git (`dev`), created the public repo `crilsen/k8s-homelab`, and pushed the initial commit.
- Implemented GitOps components (code ready, not applied): infrastructure = MetalLB 0.16.1 (+ pool), cert-manager v1.21.2 (+ self-signed issuer), ingress-nginx 4.15.1, local-path v0.0.37; platform = metrics-server 3.14.0, kube-prometheus-stack 91.4.0. ApplicationSets render them via kustomize `helmCharts` with `--enable-helm` (ADR-010).
- Added `_`-prefixed placeholders (excluded from the ApplicationSets): `_dns`, `_longhorn`, `_loki` (chart values ready), `_velero`, `_secrets` (decision-blocked). Rename to activate.

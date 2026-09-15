# Current Work

## Active

- Fase 0 (foundation): done and published at `crilsen/k8s-homelab` (branch `dev`).

## Planned

- Fase 1 — provision nodes: confirm inventory, run `prepare.yml` + `cluster-init.yml`.
- Fase 2 — baseline: MetalLB, ingress-nginx, cert-manager, storage, DNS.
- Fase 3 — GitOps: Argo CD root app + ApplicationSets, decide secret management (ADR-008).

## Blocked

- Real inventory (addresses, SSH user/key), internal domain, and MetalLB pool are unknown.
- Secret-management mechanism deferred (ADR-008) — blocks the first secret-bearing workload.

## Completed

- Adopted the portable context with real facts (PROJECT, ARCHITECTURE, CONVENTIONS, DECISIONS, TOOLS, VALIDATION).
- Created the repository skeleton: `ansible/` (inventory, group_vars, playbooks, roles), `bootstrap/`, `gitops/` (apps, layers, clusters), `docs/`.
- Documented architecture, roadmap, bootstrap, runbooks (add-node, upgrade, restore-etcd, break-glass), and certification track.
- Initialized Git (`dev`), created the public repo `crilsen/k8s-homelab`, and pushed the initial commit.

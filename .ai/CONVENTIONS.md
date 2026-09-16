# Conventions

## Observed

- No historical project conventions exist yet (the repository had no code before adoption).
- Context lives in `AGENTS.md` + `.ai/`; tool files are thin adapters (`.ai/ADAPTERS.md`).

## Recommended project conventions

### Layout

- `ansible/` — host and cluster provisioning. One inventory per topology (`single-node.ini`, `lab.ini`).
- `bootstrap/` — one-time cluster bring-up: CNI, Argo CD, root Application.
- `gitops/` — everything Argo CD reconciles. Keep it the only place cluster state is declared.
- `docs/` — architecture, roadmap, runbooks, certification map.

### Naming

- Files/dirs lowercase, hyphenated (`kube-prometheus-stack`, `ingress-nginx`).
- Kubernetes namespaces group by layer: `infrastructure`, `platform`, `workloads` (per app).
- Cluster overlays named after the topology (`single-node`, `lab`, `ha`).

### Ansible

- Idempotent tasks only; no `command`/`shell` without `changed_when`/`creates`.
- Versions, CIDRs, addresses, and domain live in `group_vars/`, never inline in playbooks.
- Roles: `common` → `container_runtime` → `kube_packages`; cluster actions in playbooks.

### Kubernetes / GitOps

- Pin chart versions; never use `latest`.
- Set `resources` requests/limits, probes, and security contexts on every workload.
- One Application per component; use ApplicationSets for per-cluster fan-out.
- Component directories prefixed with `_` are placeholders and are excluded from the ApplicationSets (`exclude: true`); rename to drop the `_` to activate. Never leave an empty component directory that the generator would pick up.
- Ordered bring-up with Argo CD sync waves (`argocd.argoproj.io/sync-wave`).
- No manual `kubectl apply` against the live cluster except documented bootstrap and break-glass steps.

### Git

- Small, focused commits; conventional-ish prefixes (`feat:`, `fix:`, `docs:`, `chore:`).
- Never commit secrets in plaintext.
- Keep the Resume block in `.ai/HANDOFF.md` current (see `.ai/LIMITS.md`).

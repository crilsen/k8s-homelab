# Architectural Decisions

## ADR-001 — Bounded learnings buffer with promotion

Status: Accepted

Context:
The template recorded state (`TASKS.md`, `HANDOFF.md`) and durable choices (`DECISIONS.md`), but had no mechanism for an agent to retain reusable, non-obvious learnings across sessions and tools.

Decision:
Introduce `.ai/LEARNINGS.md` as a bounded, append-only buffer with a fixed entry format, promotion rules, and compaction at 40 active entries. Durable learnings are promoted to `CONVENTIONS.md`, `DECISIONS.md`, `TOOLS.md`, or `VALIDATION.md` and the entry is marked `promoted`.

Reasoning:
Keeps the normative files clean and evidence-based while giving agents an explicit, portable place to capture what they learned, avoiding rediscovery and drift between tools.

Consequences:
- Learnings are portable and versioned with the repository.
- The buffer can grow and must be compacted; promotion directs durable rules to their permanent home.
- Agents must follow `.ai/workflows/capture-learning.md` rather than writing ad-hoc notes.

## ADR-002 — Agent-independent context with thin adapters

Status: Accepted

Context:
Work must continue across different agents, models, providers, and machines, including when one provider's usage limit is reached. Tool-specific files and chat history are not portable.

Decision:
Keep `AGENTS.md` and `.ai/` as the only source of truth. Any tool-specific file is a thin adapter that routes to `AGENTS.md` and contains no project facts; adapter paths are catalogued in `.ai/ADAPTERS.md`. Handoff state is carried by the Resume block in `.ai/HANDOFF.md` and the protocol in `.ai/workflows/switch-agent.md`, and must be committed and pushed or explicitly listed as uncommitted.

Reasoning:
The repository is the only medium every agent can read. Keeping adapters thin prevents drift, and centralizing handoff in version-controlled files makes agents interchangeable.

Consequences:
- Context survives agent, model, provider, and machine changes.
- Agents with lower context windows or tighter limits can resume because `AGENTS.md` stays small and `.ai/` is read on demand.
- Uncommitted work can be lost on a machine switch unless it is committed, pushed, or listed in `HANDOFF.md`.

## ADR-003 — Rolling checkpoints with usage-limit thresholds

Status: Accepted

Context:
Provider usage can be exhausted mid-task. The agent cannot always read the exact remaining quota, and losing work at the limit defeats the portability goals.

Decision:
Adopt a rolling checkpoint: the Resume block in `.ai/HANDOFF.md` is kept current after every meaningful step. Define usage thresholds in `.ai/LIMITS.md` (warn at 70%, stop starting new work and finalize at 85%). Use reported usage when the tool exposes it, plus a self-imposed work-volume proxy otherwise.

Reasoning:
A continuously current handoff makes any interruption resumable, and explicit thresholds turn an abrupt limit into a planned handoff.

Consequences:
- Interruptions and provider switches become routine rather than lossy.
- Agents must commit or list work in progress and must not claim an unobserved quota.
- Tool-specific watchers (statusline, hook, plugin) are optional and stay thin; the policy remains portable.

## ADR-004 — Use kubeadm (upstream Kubernetes), not k3s

Status: Accepted

Context:
The homelab must be close to a production environment and serve as study for CKA/CKAD/CKS. Lightweight distributions hide the control-plane mechanics those exams test.

Decision:
Provision upstream Kubernetes with `kubeadm`, on containerd, pinned to a supported minor version (currently 1.37; supported line 1.37/1.36/1.35).

Reasoning:
The exams and most self-managed production clusters are kubeadm-based and require knowledge of `kubeadm init/join/upgrade`, etcd backup/restore, certificates, static pods, and kubelet/containerd. k3s would hide most of that, trading learning and fidelity for convenience.

Consequences:
- More components to operate (CNI, LB, ingress, storage are not bundled) — mitigated by Ansible and GitOps.
- Direct certification relevance and production fidelity.
- Upgrade paths follow upstream (`kubeadm upgrade`) instead of a single binary.

## ADR-005 — One codebase for 1..N nodes

Status: Accepted

Context:
The homelab must run on a single machine, or scale to as many as desired, without maintaining divergent setups.

Decision:
Keep one Ansible inventory per topology and one GitOps tree with per-cluster overlays. Node count, addresses, domain, and storage class are variables in `gitops/clusters/<name>/` and `ansible/group_vars/`, never forks of the manifests.

Reasoning:
Duplicated manifests drift. Parameterizing the topology keeps a single source of truth for workloads and platform components.

Consequences:
- Adding a node or changing topology is a data change (inventory/overlay), not a code change.
- Overlays must stay thin; any real difference in behavior belongs in the shared component, guarded by a variable.

## ADR-006 — Argo CD is the system of record after bootstrap

Status: Accepted

Context:
Maintenance and updates must be easy and auditable, and the cluster must be reproducible from Git.

Decision:
After a one-time `bootstrap/` step (CNI + Argo CD + root Application), Argo CD reconciles `gitops/` with prune and self-heal enabled. Manual cluster changes are limited to documented bootstrap and break-glass procedures.

Reasoning:
GitOps makes the desired state reviewable, revertible, and continuous, and removes configuration drift.

Consequences:
- Every change is a pull request; Renovate automates dependency bumps.
- Break-glass changes must be back-ported into Git or they will be pruned.

## ADR-007 — Baseline component choices

Status: Accepted

Context:
The platform baseline must be chosen before the first build.

Decision:
CNI Calico, ingress-nginx, MetalLB (L2), cert-manager, metrics-server, and storage = local-path-provisioner (single node) / Longhorn (multi-node). Observability = kube-prometheus-stack + Loki. Backup = Velero + etcd snapshots.

Reasoning:
Each is production-representative, well documented, and cert-relevant, while remaining maintainable in a homelab.

Consequences:
- Storage class is an overlay variable so single-node and multi-node differ only in the overlay.
- Components are version-pinned in Git; upgrades arrive via PR.

## ADR-008 — Secret management deferred

Status: Deferred

Context:
GitOps requires secrets, but the mechanism (SOPS+age, Sealed Secrets, External Secrets+Vault) has real operational tradeoffs.

Decision:
Defer the choice. Until decided, do not commit secrets to Git and provision the few bootstrap secrets (e.g., age key, cloud credentials) out of band.

Reasoning:
The mechanism should be chosen together with the first secret-bearing workload to avoid rework.

Consequences:
- Any secret-bearing app is blocked on this decision.
- Revisit before Fase 3 (GitOps) is considered complete.

## ADR-009 — Start with a two-node topology

Status: Accepted

Context:
The homelab budget/hardware starts small but must grow without rework. A single
node is a single point of failure and cannot exercise HA; an even number of
control-plane nodes breaks etcd quorum.

Decision:
Begin with 1 control plane (`192.168.0.201`) + 1 worker (`192.168.0.202`) using
`ansible/inventory/lab.ini`. Keep `.203` as a commented third node. Use
`storageClass: local-path` until a third node exists, then switch the overlay to
Longhorn. `single-node.ini` remains supported for a one-machine build.

Reasoning:
Two nodes add a real worker without the quorum problems of two control planes,
and moving later is a data change (inventory + overlay), not a code change.

Consequences:
- No HA control plane yet; the API server and etcd live on `.201`.
- Longhorn is deferred until a third node is available (needs >=3 for a healthy replica count).
- Growing to HA = add two control-plane hosts + a kube-vip VIP and point `control_plane_endpoint` at it.

## ADR-010 — Deliver components as kustomize directories with `helmCharts`

Status: Accepted

Context:
GitOps components must be version-pinned, reviewable, and allow custom resources
(CRs) next to the chart that installs their CRDs, while staying uniform so the
ApplicationSets need no per-component metadata.

Decision:
Each component is a directory with a `kustomization.yaml` that renders its Helm
chart via `helmCharts` (with `valuesFile`) and lists any extra manifests under
`resources`. Argo CD runs kustomize with `--enable-helm`, set per Application in
`gitops/apps/appsets.yaml` (`source.kustomize.buildOptions`). CRs that depend on
chart CRDs carry `argocd.argoproj.io/sync-wave: "1"` so the CRDs apply first.
`local-path-provisioner` (no usable Helm repo) is vendored as a pinned manifest.

Reasoning:
Keeps one uniform pattern discoverable by the ApplicationSets' directory
generator, avoids Application-level chart metadata, and lets a single Application
install a chart and its CRs in the right order.

Consequences:
- Argo CD's repo-server must have `helm` available (the default image does).
- Chart versions live in `kustomization.yaml`; Renovate coverage for
  `helmCharts` is not guaranteed, so bump versions manually or verify Renovate.
- Vendored manifests (local-path) must be refreshed by hand on upgrade.

Use this ADR format for durable, meaningful decisions:

```text
## ADR-NNN - Title

Status: Proposed | Accepted | Superseded | Deprecated

Context:
...

Decision:
...

Reasoning:
...

Consequences:
...
```

Do not backfill invented history. Record decisions that are observed, expressly documented, or approved during future work.

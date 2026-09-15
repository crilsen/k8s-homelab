# GitOps (Argo CD)

Everything Argo CD reconciles lives here. The Git repository is the source of truth; the cluster follows.

## Structure

```text
apps/           ApplicationSets (one per layer) + the root app is in bootstrap/
infrastructure/ cluster-wide plumbing: metallb, ingress-nginx, cert-manager, storage, dns
platform/       cross-cutting services: metrics-server, monitoring, logging, backup
workloads/      your applications
clusters/       per-topology overlays (node count, addresses, domain, storage class)
```

## Add-a-component flow

1. Create `gitops/<layer>/<component>/` with a `kustomization.yaml` (or Helm values).
2. ApplicationSets auto-discover new directories under each layer — no edit needed.
3. Open a PR. Argo CD syncs on merge.

Bring-up order is enforced with Argo CD sync waves:

| Wave | Layer | Examples |
| --- | --- | --- |
| 0 | infrastructure (foundations) | MetalLB, cert-manager, CNI add-ons |
| 1 | infrastructure (consumers) | ingress-nginx, storage |
| 2 | platform | metrics-server, monitoring, logging, backup |
| 3 | workloads | applications |

## Repository URL

The ApplicationSets reference this repository by URL, currently
`https://github.com/crilsen/k8s-homelab.git`. `bootstrap/root-app.yaml` takes it
from `GITOPS_REPO_URL` at apply time. If the repo moves, update the `repoURL`
fields in `gitops/apps/appsets.yaml`.

## Per-cluster overlays

`clusters/<name>/config.yaml` holds the values that differ between topologies (domain, MetalLB pool, storage class). ApplicationSets reference the overlay for the cluster they target, so a single-node build and an N-node build share every manifest.

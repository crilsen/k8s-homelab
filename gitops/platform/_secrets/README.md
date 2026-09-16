# _secrets (placeholder — not reconciled)

Secret management for GitOps. Blocked on **ADR-008** (choice deferred).

## Candidates

| Approach | Notes |
| --- | --- |
| SOPS + age | Encrypt secrets in Git; age key stays offline. Simplest. |
| Sealed Secrets | Controller in-cluster; encrypt per namespace. |
| External Secrets Operator + Vault/1Password/Bitwarden | Strongest; more moving parts. |

## Until it is decided

- Do **not** commit plaintext secrets. `.gitignore` already excludes common
  key/secret filenames.
- Create the few needed secrets out of band (`kubectl create secret ...`) and
  reference them from workloads/manifests.
- First consumers that will need this: Grafana admin password
  (`kube-prometheus-stack`), MetalLB/cert-manager DNS credentials, Velero.

## How to activate

1. Record the decision in `.ai/DECISIONS.md` (replace ADR-008's `Deferred`).
2. Add the controller's manifests + `kustomization.yaml` here.
3. Rename this directory to `secrets`.

# Tools

## Current availability

Planned toolchain: `ansible` (+ `ansible-lint`), `kubeadm`/`kubelet`/`kubectl`, `containerd`, `helm`, `kustomize`, `yamllint`, `shellcheck`, `sops` (+ `age`), `renovate`.

Nothing is installed or verified on the hosts yet. Cluster-specific addresses, credentials, and SSH access are **Unknown / not determined**.

## Allowed without additional authorization

- Read and search repository files.
- Make scoped, task-related edits.
- Run `ansible-playbook --syntax-check` / `--check` (dry run), `ansible-lint`, `yamllint`, `helm lint`, `helm template`, `kustomize build`, `shellcheck`.
- Run read-only cluster commands (`kubectl get`, `describe`, `diff`, `--dry-run=client`).
- Run `kubeadm` in dry-run/`config images list` style checks.
- Update this portable context.

## Requires explicit authorization

- `kubeadm init`, `kubeadm join`, `kubeadm upgrade`, `kubeadm reset`.
- `kubectl apply/delete/patch` against a real cluster, and any Argo CD sync that changes live state.
- `ansible-playbook` runs without `--check` against real hosts.
- etcd restore, node drains/reboots, cluster or host OS upgrades.
- Secret changes, destructive state operations, paid resources, or any external side effect.

## Command safety by tool

| Tool | Safe | Restricted |
| --- | --- | --- |
| Ansible | `--syntax-check`, `--check`, `ansible-lint` | real runs / `--limit` against live hosts |
| Kubernetes | `get`, `describe`, `diff`, client dry-run | real cluster apply/delete |
| Helm | `lint`, `template` | install/upgrade on real clusters |
| kubeadm | version/config inspection, dry-run | init/join/upgrade/reset |
| Static analysis | `yamllint`, `shellcheck`, `tflint`, `checkov`, `trivy` | follow impact rules |

Never store secrets or private keys in this file.

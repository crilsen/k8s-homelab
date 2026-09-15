# Validation

## Completion rule

Before completion, run every applicable, available, and safe check. Report each as **Validated**, **Partially validated**, or **Not validated**, with the reason for anything not run. Never claim validation that did not occur.

## Repository-level (available now)

1. `yamllint ansible/ gitops/ bootstrap/` — YAML syntax and style.
2. `ansible-lint ansible/` — Ansible best practices.
3. `ansible-playbook -i ansible/inventory/single-node.ini ansible/playbooks/<play>.yml --syntax-check`.
4. `shellcheck bootstrap/*.sh docs/runbooks/*.sh` (when scripts exist).
5. `helm template <chart> <repo>/<chart> -f <values>` and `kustomize build <overlay>`.

## Cluster-level (once a cluster exists)

1. `kubectl get nodes -o wide` → all `Ready`.
2. `kubectl -n kube-system get pods` → control plane and CNI healthy.
3. `kubectl get --raw='/readyz?verbose'` and `/livez`.
4. Argo CD: root Application `Synced` + `Healthy`, no `OutOfSync`.
5. Storage: a test PVC binds and a pod can mount it.
6. Ingress/TLS: a test app is reachable over HTTPS via MetalLB + cert-manager.
7. Backup: take an etcd snapshot and a Velero backup, then perform a restore drill.

## Certification readiness (map in `docs/certification-track.md`)

- CKA: install with kubeadm, upgrade one minor version, join a node, etcd backup/restore, RBAC, troubleshooting.
- CKAD: workloads, probes, config, services/ingress, resource management.
- CKS: NetworkPolicy, Pod Security, RBAC hardening, secrets, runtime/admission controls.

No cluster-specific validation has been run yet.

# Runbook — Upgrade the cluster

**Impact:** disruptive if done incorrectly; upgrade one minor version at a time
(e.g. 1.36 → 1.37; never skip a minor).
**Authorization:** required.

## Preconditions

- A current etcd snapshot and a Velero backup exist.
- All nodes `Ready`; no degraded control-plane component.

## Steps

1. Back up etcd and workloads (see `docs/runbooks/restore-etcd.md`).
2. Raise `kubernetes_version`, `kubernetes_package_version`, and the apt repo URL
   in `ansible/group_vars/all/main.yml`.
3. Upgrade the first control plane:

   ```bash
   # on the first control-plane node
   apt-get update && apt-get install -y kubeadm=<new-version>
   kubeadm upgrade plan
   kubeadm upgrade apply v<new-version>
   ```

4. Upgrade the remaining control-plane nodes (`kubeadm upgrade node`), one at a
   time, after draining.
5. Upgrade kubelet/kubectl packages and restart kubelet on each node.
6. Drain, `kubeadm upgrade node`, uncordon each worker.
7. Raise the CNI/add-on versions via GitOps PRs (Argo CD syncs).

## Verification

```bash
kubectl get nodes -o wide
kubectl get --raw='/readyz?verbose'
kubectl -n argocd get applications
```

## Rollback

Kubernetes does not support downgrades. Restore from the etcd snapshot taken in
step 1 if the upgrade fails.

## Notes

Ansible can orchestrate this, but the exact commands must be reviewed per
release. The placeholder `ansible/playbooks/upgrade.yml` intentionally refuses to
run until this runbook is followed.

# Runbook — Break glass

**When:** Argo CD is down, the cluster is unreachable, or an outage must be
resolved faster than a Git PR allows.

**Impact:** high. **Authorization:** required.

## Principles

- Git is still the source of truth. Any manual fix must be back-ported to Git, or
  Argo CD will revert it (prune/self-heal) once it recovers.
- Record every manual action so it can be replayed as a commit.

## If Argo CD is unavailable

1. Make the minimum manual change with `kubectl` to restore service.
2. Note the exact change (command + manifest diff).
3. Once Argo CD is back: commit the change to `gitops/`, then let Argo sync.
   If Argo already reverted it, re-apply from Git.

## If the API is unreachable

1. Check control-plane nodes and static pods:
   `kubectl -n kube-system get pods` (or `crictl ps` on the node).
2. Check etcd health and certificates (`kubeadm certs check-expiration`).
3. If certificates expired, renew with `kubeadm certs renew all` and restart the
   control-plane static pods.
4. If etcd is corrupted, follow `docs/runbooks/restore-etcd.md`.

## After the incident

- Write the root cause and the corrective commit in `.ai/HANDOFF.md` and, if
  durable, in `.ai/DECISIONS.md` or `.ai/LEARNINGS.md`.
- Add or update a runbook so the next occurrence is routine.

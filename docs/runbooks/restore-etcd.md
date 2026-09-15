# Runbook — Back up and restore etcd

**Impact:** restore is highly disruptive (cluster-wide).
**Authorization:** required.

## Backup (on any control-plane node)

```bash
sudo ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /var/backups/etcd-$(date +%Y%m%d-%H%M%S).db
```

Verify the snapshot:

```bash
sudo ETCDCTL_API=3 etcdctl --write-out=table snapshot status <snapshot.db>
```

Automate snapshots with a CronJob (Velero plus a kubeadm etcd snapshot CronJob).

## Restore (single-node / stacked etcd)

1. Stop the API server and etcd on every control-plane node.
2. Move the existing data directory aside: `/var/lib/etcd`.
3. Restore on one node:

   ```bash
   sudo ETCDCTL_API=3 etcdctl snapshot restore <snapshot.db> \
     --data-dir=/var/lib/etcd
   ```

4. On the first control-plane node, re-run `kubeadm init` with
   `--ignore-preflight-errors=DirAvailable--var-lib-etcd` (or the documented
   `kubeadm` etcd restore flow for your version).
5. Start kubelet on all control-plane nodes and verify:

   ```bash
   kubectl get nodes
   kubectl get --raw='/readyz?verbose'
   ```

## Notes

- Prefer recovering the control plane one node at a time; do not wipe all nodes at once.
- After restore, run `kubeadm init phase upload-certs --upload-certs` if
  additional control-plane nodes need to rejoin.
- Always practice this in a throwaway cluster before relying on it.

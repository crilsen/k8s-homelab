# _longhorn (placeholder — not reconciled)

Replicated block storage (PVCs survive a node loss), the multi-node counterpart
to `local-path`.

## Why it is not enabled

Longhorn wants **>=3 nodes** for a healthy default replica count. This homelab
currently has two nodes, so `local-path` is the active default StorageClass.
Enable Longhorn once a third node is added.

Prerequisite already handled by `ansible/roles/common`: `open-iscsi` +
`iscsid`/`multipathd` are needed on every node.

## How to activate

1. Verify `open-iscsi` is running on all nodes.
2. Rename this directory to `longhorn`.
3. Set `storageClass` to `longhorn` in the matching cluster overlay
   (`gitops/clusters/<name>/config.yaml`) once you intend it as the default, and
   adjust `persistence.defaultClass` in `values.yaml` accordingly.

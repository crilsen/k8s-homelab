# _velero (placeholder — not reconciled)

Backups of cluster resources and persistent volumes (via the node agent), for
disaster recovery and a tested restore drill.

## Why it is not enabled

Velero needs a **backup storage location** and credentials. Those depend on the
secret-management decision (ADR-008) and on whether you use object storage or an
in-cluster MinIO. Enable it together with that decision.

## Suggested shape when activated

- Chart: `vmware-tanzu/velero` (12.1.0), namespace `velero`.
- `credentials.useSecret: true` with `existingSecret` created out of band (never
  committed).
- A `BackupStorageLocation` (S3-compatible or MinIO) and optionally a
  `VolumeSnapshotLocation`.
- `deployNodeAgent: true` for file-system backups of volumes.
- A `Schedule` resource (e.g., daily) plus a documented restore procedure in
  `docs/runbooks/`.
- etcd snapshots stay separate: see `docs/runbooks/restore-etcd.md`.

## How to activate

1. Decide blob storage + credentials.
2. Add `kustomization.yaml` (+ values / `BackupStorageLocation` / `Schedule`).
3. Rename this directory to `velero`.

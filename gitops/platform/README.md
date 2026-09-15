# platform

Cross-cutting services reconciled after infrastructure.

| Directory | Component | Chart | Version | Status |
| --- | --- | --- | --- | --- |
| `metrics-server/` | metrics-server | `metrics-server/metrics-server` | 3.14.0 | ready |
| `kube-prometheus-stack/` | Prometheus + Grafana + Alertmanager | `prometheus-community/kube-prometheus-stack` | 91.4.0 | ready |

## Not yet implemented

- `loki/` — log aggregation (Grafana Loki + Alloy). Chart values are non-trivial
  and version-sensitive; add once a cluster is available to validate.
- `velero/` — backups. Needs a backup storage location (object storage or a
  MinIO in-cluster) and credentials, which depend on ADR-008.
- `secrets/` — secret management. Blocked on ADR-008.

## Notes

- Each component is a separate Argo CD Application (wave 2).
- Enable `serviceMonitor` on infrastructure components only after this layer has
  installed the Prometheus Operator CRDs.

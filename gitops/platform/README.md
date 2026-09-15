# platform

Cross-cutting services reconciled after infrastructure. Each subdirectory becomes an Argo CD Application (wave 2).

| Directory | Component | Notes |
| --- | --- | --- |
| `metrics-server/` | metrics-server | Required by `kubectl top` and HPAs |
| `kube-prometheus-stack/` | Prometheus + Grafana + Alertmanager | Dashboards and alerts |
| `loki/` | Loki + Promtail/Alloy | Log aggregation |
| `velero/` | Velero | Cluster + volume backups (with restic/Kopia) |
| `secrets/` | Secret management | Blocked on ADR-008 (SOPS+age / Sealed Secrets / ESO) |

Only create a directory once you add its manifests.

# platform

Cross-cutting services reconciled after infrastructure.

| Directory | Component | Chart | Version | Status |
| --- | --- | --- | --- | --- |
| `metrics-server/` | metrics-server | `metrics-server/metrics-server` | 3.14.0 | ready |
| `kube-prometheus-stack/` | Prometheus + Grafana + Alertmanager | `prometheus-community/kube-prometheus-stack` | 91.4.0 | ready |

## Placeholders (not reconciled)

Directories prefixed with `_` are ignored by the ApplicationSet (see the exclude
rule in `gitops/apps/appsets.yaml`). Rename to drop the `_` to activate one.

- `_loki/` — log aggregation (Grafana Loki). `kustomization.yaml` + `values.yaml`
  are ready; validate against the chart before enabling.
- `_velero/` — backups. Needs blob storage + credentials (ADR-008).
- `_secrets/` — secret management. Blocked on ADR-008.

## Notes

- Each component is a separate Argo CD Application (wave 2).
- Enable `serviceMonitor` on infrastructure components only after this layer has
  installed the Prometheus Operator CRDs.

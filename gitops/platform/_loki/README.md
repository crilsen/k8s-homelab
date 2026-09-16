# _loki (placeholder — not reconciled)

Log aggregation: Grafana Loki (store) + a collector (Alloy/Promtail) shipping pod
logs. Query from the Grafana that `kube-prometheus-stack` already installs.

## Why it is not enabled

The Loki chart's values are version-sensitive and were not validated against a
cluster. The `values.yaml` here follows the official `SingleBinary` example for a
small homelab.

## How to activate

1. Rename this directory to `loki`.
2. Add a `ServiceMonitor`/datasource so Grafana picks Loki up (or set
   `grafana.sidecar.datasources` in `kube-prometheus-stack`).
3. Verify the chart's current values against the release notes before enabling —
   chart version 7.3.0 is pinned in `kustomization.yaml`.

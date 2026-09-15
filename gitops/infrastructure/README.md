# infrastructure

Cluster-wide plumbing. Each subdirectory becomes its own Argo CD Application.

| Directory | Component | Chart / source | Version | Status |
| --- | --- | --- | --- | --- |
| `metallb/` | MetalLB + LAN address pool | `metallb/metallb` | 0.16.1 | ready |
| `cert-manager/` | cert-manager + self-signed `ClusterIssuer` | `jetstack/cert-manager` | v1.21.2 | ready |
| `ingress-nginx/` | ingress-nginx (default IngressClass) | `ingress-nginx/ingress-nginx` | 4.15.1 | ready |
| `local-path/` | local-path-provisioner (default StorageClass) | vendored manifest v0.0.37 | — | ready |

Components are rendered with kustomize `helmCharts` (Argo CD runs kustomize with
`--enable-helm`, set on each Application in `gitops/apps/appsets.yaml`).

## Not yet implemented

- `dns/` — internal DNS wildcard (`*.<domain>`) to the MetalLB address. Needs a
  LAN DNS server; decide approach (CoreDNS/ExternalDNS vs router) first.
- `longhorn/` — replicated storage for >=3 nodes. Use instead of `local-path`
  once a third node exists; switch `storageClass` in the cluster overlay.

## Notes

- The MetalLB pool (`metallb/addresspool.yaml`) must match the cluster overlay's
  `metalLbAddressPool`.
- Resources that need a CRD installed by the same Application use
  `argocd.argoproj.io/sync-wave: "1"` so the CRDs exist first.

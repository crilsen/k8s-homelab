# infrastructure

Cluster-wide plumbing. Each subdirectory becomes its own Argo CD Application (wave 0/1).

| Directory | Component | Wave | Notes |
| --- | --- | --- | --- |
| `metallb/` | MetalLB | 0 | L2 address pool from the cluster overlay |
| `cert-manager/` | cert-manager | 0 | Internal CA or Let's Encrypt DNS-01 |
| `local-path/` | local-path-provisioner | 1 | Single-node storage |
| `longhorn/` | Longhorn | 1 | Multi-node replicated storage |
| `ingress-nginx/` | ingress-nginx | 1 | IngressClass `nginx` |
| `dns/` | internal DNS | 1 | Wildcard `*.<domain>` to the MetalLB VIP |

Only create a directory once you add its manifests; an empty directory produces an empty Application.
Storage is an either/or choice driven by the cluster overlay (`storageClass`).

# _dns (placeholder — not reconciled)

Internal DNS so services resolve by name on the LAN, e.g.
`grafana.lab.local` and a wildcard `*.lab.local` pointing at the MetalLB address.

## Why it is not implemented

It requires a decision that depends on your router/LAN:

- **Router/DHCP option** — point DNS at a small in-cluster resolver and serve
  `*.lab.local` itself.
- **ExternalDNS** — manage records in your DNS provider from Ingresses/Service
  annotations.

Options to consider once decided:

| Approach | Chart / component | Notes |
| --- | --- | --- |
| CoreDNS custom zone | in-cluster CoreDNS ConfigMap | Serve `lab.local` and forward the rest |
| ExternalDNS + provider | `external-dns` (kubernetes-sigs) | Needs provider API credentials (ADR-008) |
| Pi-hole / AdGuard | not in-cluster | Simplest for a home LAN; add a wildcard to the MetalLB IP |

## How to activate

1. Decide the approach above.
2. Add `kustomization.yaml` (+ values/manifests) in this directory.
3. Rename this directory to `dns` (remove the leading `_`) so the
   `infrastructure` ApplicationSet picks it up.

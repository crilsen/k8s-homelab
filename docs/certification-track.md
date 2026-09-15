# Certification track (CKA / CKAD / CKS)

The homelab is built with kubeadm precisely so the operational surface matches
the exams. Use this map to convert homelab tasks into exam practice.

## CKA — Certified Kubernetes Administrator

| Topic | Where in this repo |
| --- | --- |
| Cluster architecture, control plane, etcd, static pods | `ansible/playbooks/cluster-init.yml`, `kubeadm_control_plane` role |
| Install with kubeadm, join nodes | `docs/bootstrap.md`, `docs/runbooks/add-node.md` |
| Upgrade a cluster one minor version | `docs/runbooks/upgrade-cluster.md` |
| etcd backup and restore | `docs/runbooks/restore-etcd.md` |
| Certificates and kubeconfig | control-plane role, break-glass runbook |
| RBAC, service accounts | add a demo RBAC manifest under `gitops/workloads/` |
| Networking, Services, Ingress, CNI | MetalLB + ingress-nginx in `gitops/infrastructure/` |
| Storage: PV/PVC, StorageClass | local-path / Longhorn in `gitops/infrastructure/` |
| Troubleshooting | break-glass runbook, `kubectl describe`/logs practice |

## CKAD — Certified Kubernetes Application Developer

| Topic | Where in this repo |
| --- | --- |
| Workloads, Deployments, Jobs, CronJobs | `gitops/workloads/<app>/` |
| Configuration: ConfigMaps, Secrets | workloads + `platform/secrets` (ADR-008) |
| Probes, resource requests/limits | required in every workload (conventions) |
| Services, Ingress, NetworkPolicy | `gitops/infrastructure/` |
| Observability | `platform/metrics-server`, `kube-prometheus-stack`, `loki` |
| Rolling updates and rollbacks | Deployments managed by Argo CD |

## CKS — Certified Kubernetes Security Specialist

| Topic | Where in this repo |
| --- | --- |
| Cluster hardening, CIS benchmarks | node prep (`common` role), break-glass runbook |
| NetworkPolicy | Calico CNI + policies per workload |
| Pod Security Standards / admission | namespace labels + policies in `gitops/` |
| Secrets management | `platform/secrets` (ADR-008) |
| Runtime security, seccomp, AppArmor | workload securityContext |
| Supply chain / image scanning | Renovate + Trivy in CI |
| RBAC least privilege | scoped ServiceAccounts and Roles |

## Practice loop

1. Break something deliberately (kill a control-plane static pod, drain a node,
   corrupt a PVC) in the lab.
2. Fix it using only the CLI, under time pressure.
3. Then express the fix in Git and let Argo reconcile.

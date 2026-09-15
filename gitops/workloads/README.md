# workloads

Applications. Each subdirectory becomes an Argo CD Application (wave 3) and
defines its own Kubernetes namespace (the namespace defaults to the directory name).

Suggested layout per app:

```text
gitops/workloads/<app>/
├─ namespace.yaml
├─ kustomization.yaml
├─ deployment.yaml
├─ service.yaml
├─ ingress.yaml
└─ pvc.yaml
```

Every workload should set resource requests/limits, liveness/readiness probes,
a security context, and (once decided) reference secrets as secret objects.

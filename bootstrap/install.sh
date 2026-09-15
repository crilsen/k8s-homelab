#!/usr/bin/env bash
#
# One-time cluster bring-up after `ansible-playbook .../cluster-init.yml`:
#   1. apply the CNI (cluster is NotReady until then)
#   2. install Argo CD
#   3. apply the root Application, then GitOps takes over
#
# Requires: kubectl configured for the new cluster, and network access.
#
# Usage:
#   GITOPS_REPO_URL=https://github.com/<you>/k8s-homelab.git ./bootstrap/install.sh
#
# Optional overrides:
#   CNI_MANIFEST_URL   (default: Calico, must match ansible/group_vars/all/main.yml)
#   ARGOCD_VERSION     (default: stable)
#   ARGOCD_NAMESPACE   (default: argocd)
#   GITOPS_REVISION    (default: main)

set -euo pipefail

CNI_MANIFEST_URL="${CNI_MANIFEST_URL:-https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/calico.yaml}"
ARGOCD_VERSION="${ARGOCD_VERSION:-stable}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
GITOPS_REVISION="${GITOPS_REVISION:-main}"
GITOPS_REPO_URL="${GITOPS_REPO_URL:-}"

if [[ -z "${GITOPS_REPO_URL}" ]]; then
  echo "error: set GITOPS_REPO_URL to this repository's Git URL" >&2
  exit 1
fi

echo "==> Applying CNI: ${CNI_MANIFEST_URL}"
kubectl apply -f "${CNI_MANIFEST_URL}"

echo "==> Waiting for nodes to become Ready"
kubectl wait --for=condition=Ready node --all --timeout=300s

echo "==> Installing Argo CD (${ARGOCD_VERSION}) in namespace ${ARGOCD_NAMESPACE}"
kubectl create namespace "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n "${ARGOCD_NAMESPACE}" \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

echo "==> Waiting for Argo CD server"
kubectl -n "${ARGOCD_NAMESPACE}" rollout status deployment/argocd-server --timeout=300s

echo "==> Applying the root Application (app-of-apps)"
sed -e "s|\${GITOPS_REPO_URL}|${GITOPS_REPO_URL}|g" \
    -e "s|\${GITOPS_REVISION}|${GITOPS_REVISION}|g" \
    "$(dirname "$0")/root-app.yaml" | kubectl apply -f -

echo
echo "Done. Argo CD is reconciling gitops/ from ${GITOPS_REPO_URL}@${GITOPS_REVISION}."
echo "Get the initial admin password with:"
echo "  kubectl -n ${ARGOCD_NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"

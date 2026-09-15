# Runbook — Add a node

**Impact:** additive; running workloads are not disrupted.
**Authorization:** required (touches live hosts and cluster membership).

## Preconditions

- New host reachable over SSH with the same Ubuntu version and sudo access.
- Kubelet/kubeadm versions match the cluster's pinned version.

## Steps

1. Add the host to the inventory (`k8s_workers` or `k8s_control_plane`) in
   `ansible/inventory/<topology>.ini`.

2. Prepare the host:

   ```bash
   ansible-playbook -i ansible/inventory/lab.ini ansible/playbooks/prepare.yml --limit <new-host>
   ```

3. Join it:

   ```bash
   ansible-playbook -i ansible/inventory/lab.ini ansible/playbooks/join.yml --limit <new-host>
   ```

4. Verify:

   ```bash
   kubectl get nodes -o wide
   kubectl get pods -n kube-system -o wide --field-selector spec.nodeName=<new-host>
   ```

## Rollback

On the node: `kubeadm reset -f`, then remove the host from the inventory. Delete
the Node object if it lingers: `kubectl delete node <new-host>`.

## Notes

- For a control-plane host, `join.yml` runs `kubeadm join --control-plane` using
  a freshly uploaded certificate key.
- Storage (Longhorn) discovers the new disks automatically; verify replica
  rebalancing under the Longhorn UI.

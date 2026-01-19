clusterctl get kubeconfig -n $CLUSTER_NAMESPACE openstack-testcluster > /tmp/kubeconfig
kubectl get nodes --kubeconfig /tmp/kubeconfig

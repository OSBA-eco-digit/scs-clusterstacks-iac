# Create secret for CAPO
kubectl create secret -n $CLUSTER_NAMESPACE generic openstack --from-file=clouds.yaml=$OS_CLIENT_CONFIG_FILE --dry-run=client -oyaml | kubectl apply -f -

# Prepare the Secret as it will be deployed in the Workload Cluster
kubectl create secret -n kube-system generic clouds-yaml --from-file=clouds.yaml=$OS_CLIENT_CONFIG_FILE --dry-run=client -oyaml > clouds-yaml-secret

# Add the Secret to the ClusterResourceSet Secret in the Management Cluster
kubectl create -n $CLUSTER_NAMESPACE secret generic clouds-yaml --from-file=clouds-yaml-secret --type=addons.cluster.x-k8s.io/resource-set --dry-run=client -oyaml | kubectl apply -f -

export CLUSTER_NAMESPACE=cluster
export CLUSTER_NAME=my-cluster
export CLUSTERSTACK_NAMESPACE=cluster
export CLUSTERSTACK_VERSION=v1
export OS_CLIENT_CONFIG_FILE=${PWD}/clouds.yaml
kubectl create namespace $CLUSTER_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

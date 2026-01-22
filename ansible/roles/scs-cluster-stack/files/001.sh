# Create bootstrap cluster
kind create cluster

# Init Cluster API
export CLUSTER_TOPOLOGY=true
export EXP_CLUSTER_RESOURCE_SET=true
export EXP_RUNTIME_SDK=true
kubectl apply -f https://github.com/k-orc/openstack-resource-controller/releases/latest/download/install.yaml
clusterctl init --infrastructure openstack:v0.12.6

kubectl -n capi-system rollout status deployment
kubectl -n capo-system rollout status deployment

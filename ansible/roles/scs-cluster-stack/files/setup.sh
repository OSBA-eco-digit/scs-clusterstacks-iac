#!/bin/sh
######################################################################

export CLOUDS_YAML="clouds.yaml"
export CIDR_PODS="172.16.0.0/16"
export CIDR_NODES="192.168.0.0/24"
export CIDR_SERVICES="10.0.0.0/8"
export PROVIDER="openstack"
export CLUSTER_NAME="mycluster"
export CLUSTER_NAMESPACE="myclusterns"
export CLUSTER_TOPOLOGY="true"
export DOMAIN="mydomain.local"
export EXP_CLUSTER_RESOURCE_SET="true"
export EXP_RUNTIME_SDK="true"
export KUBERNETES_VERSION_MAJOR="1.34"
export KUBERNETES_VERSION_PATCH="3"
export KUBESYS_SECRET="${PWD}/kubesys-secret"
export STACK_NAME="mystack"
export STACK_NAMESPACE="mystackns"
export STACK_VERSION="v1"
       KUBVERMAJ=$(echo $KUBERNETES_VERSION_MAJOR | sed "s/\./\-/g")
export CLUSTER_CLASS="openstack-scs2-$KUBVERMAJ-$STACK_VERSION"
export KUBERNETES_VERSION="$KUBERNETES_VERSION_MAJOR.$KUBERNETES_VERSION_PATCH"
######################################################################

docker --version
clusterctl version
helm version
kubectl version
######################################################################

[ -f $CLOUDS_YAML ] || exit 1
######################################################################

### Create bootstrap cluster
kind create cluster

### Init Cluster API
kubectl apply -f https://github.com/k-orc/openstack-resource-controller/releases/latest/download/install.yaml
clusterctl init --infrastructure openstack
kubectl -n capi-system rollout status deployment
kubectl -n capo-system rollout status deployment
######################################################################

### Install CSO and CSPO
helm upgrade -i cso -n cso-system --create-namespace oci://registry.scs.community/cluster-stacks/cso
kubectl -n cso-system rollout status deployment
######################################################################

kubectl create namespace $CLUSTER_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace $STACK_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
######################################################################

### Create secret for CAPO
kubectl create secret -n $CLUSTER_NAMESPACE generic plusserver --from-file=clouds.yaml=$CLOUDS_YAML --dry-run=client -oyaml | kubectl apply -f -
kubectl create secret -n $CLUSTER_NAMESPACE generic scaleup --from-file=clouds.yaml=$CLOUDS_YAML --dry-run=client -oyaml | kubectl apply -f -
kubectl create secret -n $CLUSTER_NAMESPACE generic $PROVIDER --from-file=clouds.yaml=$CLOUDS_YAML --dry-run=client -oyaml | kubectl apply -f -

### Prepare the Secret as it will be deployed in the Workload Cluster
kubectl create secret -n kube-system generic clouds-yaml --from-file=clouds.yaml=$CLOUDS_YAML --dry-run=client -oyaml >$KUBESYS_SECRET

### Add the Secret to the ClusterResourceSet Secret in the Management Cluster
kubectl create secret -n $CLUSTER_NAMESPACE generic clouds-yaml --from-file=clouds-yaml=$KUBESYS_SECRET --type=addons.cluster.x-k8s.io/resource-set --dry-run=client -oyaml | kubectl apply -f -
######################################################################

sleep 7
######################################################################

cat <<EOF | kubectl apply -f -
apiVersion: addons.cluster.x-k8s.io/v1beta1
kind: ClusterResourceSet
metadata:
  name: clouds-yaml
  namespace: $CLUSTER_NAMESPACE
spec:
  strategy: "Reconcile"
  clusterSelector:
    matchLabels:
      managed-secret: clouds-yaml
  resources:
    - name: clouds-yaml
      kind: Secret
EOF
######################################################################

### Apply ClusterStack resource
cat <<EOF | kubectl apply -f -
apiVersion: clusterstack.x-k8s.io/v1alpha1
kind: ClusterStack
metadata:
  name: $STACK_NAME
  namespace: $STACK_NAMESPACE
spec:
  autoSubscribe: false
  channel: "stable"
  kubernetesVersion: "$KUBERNETES_VERSION_MAJOR"
  name: scs2
  noProvider: true
  provider: openstack
  versions:
    - $STACK_VERSION
EOF
######################################################################

### Apply Cluster resource
cat <<EOF | kubectl apply -f -
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  name: $CLUSTER_NAME
  namespace: $CLUSTER_NAMESPACE
  labels:
    managed-secret: clouds-yaml
spec:
  clusterNetwork:
    pods:
      cidrBlocks:
      - "$CIDR_PODS"
    serviceDomain: $DOMAIN
    services:
      cidrBlocks:
      - "$CIDR_SERVICES"
  topology:
    variables:
      - name: apiServerLoadBalancer
        value: none
      - name: nodeCIDR
        value: "$CIDR_NODES"
    class: "$CLUSTER_CLASS"
    classNamespace: $STACK_NAMESPACE
    controlPlane:
      replicas: 1
    version: "$KUBERNETES_VERSION"
    workers:
      machineDeployments:
        - class: default-worker
          name: md-0
          replicas: 1
EOF
######################################################################

### NEVER WORKED; comment it.

# clusterctl get kubeconfig -n $CLUSTER_NAMESPACE $CLUSTER_NAME >/tmp/kubeconfig
# kubectl get nodes --kubeconfig /tmp/kubeconfig

# Apply Cluster resource
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
      - "172.16.0.0/16"
    serviceDomain: cluster.local
    services:
      cidrBlocks:
      - "10.96.0.0/12"
  topology:
    variables:
    class: openstack-scs2-1-33-$CLUSTERSTACK_VERSION
    classNamespace: $CLUSTERSTACK_NAMESPACE
    controlPlane:
      replicas: 1
    version: v1.33.4
    workers:
      machineDeployments:
        - class: default-worker
          name: md-0
          replicas: 1
EOF

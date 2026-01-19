# Apply ClusterStack resource
cat <<EOF | kubectl apply -f -
apiVersion: clusterstack.x-k8s.io/v1alpha1
kind: ClusterStack
metadata:
  name: openstack
  namespace: $CLUSTERSTACK_NAMESPACE
spec:
  provider: openstack
  name: scs2
  kubernetesVersion: "1.33"
  channel: stable
  autoSubscribe: false
  noProvider: true
  versions:
    - $CLUSTERSTACK_VERSION
EOF

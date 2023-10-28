#!/bin/bash
set -euo pipefail


### scylla main cluster
echo "Removing the scylla cluster..."
kubectl delete -f ./scylladb-full-manifests/cluster.yaml
sleep 5

### scylla manager
echo "Removing the scylla manager cluster..."
kubectl delete -f ./scylladb-full-manifests/common/manager.yaml
sleep 5

### Remove local volume provisioner
echo "Uninstalling local volume provisioner..."
kubectl -n local-csi-driver delete -f ./scylladb-full-manifests/common/local-volume-provisioner/local-csi-driver/
sleep 5
echo "Uninstalling the XFS storageclass..."
kubectl delete -f ./scylladb-full-manifests/common/local-volume-provisioner/storageclass_xfs.yaml

### Remove RAID0 node configuration
kubectl delete -f ./scylladb-full-manifests/nodeconfig-alpha.yaml
sleep 5

### scylla operator
echo "Removing the scylla operator..."
kubectl delete -f ./scylladb-full-manifests/common/operator.yaml
sleep 10

### cert manager
echo "Removing the cert manger..."
kubectl delete -f ./scylladb-full-manifests/common/cert-manager.yaml

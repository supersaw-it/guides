#!/bin/bash
set -euo pipefail

### cert manager
echo "Removing the cert manger..."
kubectl delete -f ./scylladb-full-manifests/common/cert-manager.yaml

### scylla operator
echo "Removing the scylla operator..."
kubectl delete -f ./scylladb-full-manifests/common/operator.yaml

### Remove RAID0 node configuration
kubectl delete -f ./scylladb-full-manifests/nodeconfig-alpha.yaml

### Install local volume provisioner
echo "Uninstalling local volume provisioner..."
kubectl -n local-csi-driver delete -f ./scylladb-full-manifests/common/local-volume-provisioner/local-csi-driver/
echo "Uninstalling the XFS storageclass..."
kubectl delete -f ./scylladb-full-manifests/common/local-volume-provisioner/storageclass_xfs.yaml

### scylla manager
echo "Removing the scylla manager cluster..."
kubectl delete -f ./scylladb-full-manifests/common/manager.yaml

### scylla main cluster
echo "Removing the scylla cluster..."
kubectl delete -f ./scylladb-full-manifests/cluster.yaml
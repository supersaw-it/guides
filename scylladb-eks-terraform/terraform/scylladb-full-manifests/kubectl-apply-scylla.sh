#!/bin/bash
set -euo pipefail

function wait-for-object-creation {
    for i in {1..30}; do
        { kubectl -n "${1}" get "${2}" && break; } || sleep 1
    done
}

### cert manager
echo "Starting the cert manger..."
kubectl apply -f ./scylladb-full-manifests/common/cert-manager.yaml
kubectl wait --for condition=established --timeout=60s crd/certificates.cert-manager.io crd/issuers.cert-manager.io
wait-for-object-creation cert-manager deployment.apps/cert-manager-webhook
kubectl -n cert-manager rollout status --timeout=5m deployment.apps/cert-manager-webhook

### scylla operator
echo "Starting the scylla operator..."
kubectl apply -f ./scylladb-full-manifests/common/operator.yaml
kubectl wait --for condition=established crd/nodeconfigs.scylla.scylladb.com
kubectl wait --for condition=established crd/scyllaclusters.scylla.scylladb.com
wait-for-object-creation scylla-operator deployment.apps/scylla-operator
kubectl -n scylla-operator rollout status --timeout=5m deployment.apps/scylla-operator
kubectl -n scylla-operator rollout status --timeout=5m deployment.apps/webhook-server

### Configure nodes
kubectl apply -f ./scylladb-full-manifests/nodeconfig-alpha.yaml
wait-for-object-creation default nodeconfig.scylla.scylladb.com/cluster

### Install local volume provisioner
echo "Installing local volume provisioner..."
kubectl -n local-csi-driver apply --server-side -f ./scylladb-full-manifests/common/local-volume-provisioner/local-csi-driver/
wait-for-object-creation local-csi-driver daemonset.apps/local-csi-driver
kubectl -n local-csi-driver rollout status --timeout=5m daemonset.apps/local-csi-driver
kubectl apply --server-side -f ./scylladb-full-manifests/common/local-volume-provisioner/storageclass_xfs.yaml
echo "Your disks are ready to use."

### scylla manager
echo "Starting the scylla manager cluster..."
kubectl apply -f ./scylladb-full-manifests/common/manager.yaml
wait-for-object-creation scylla-manager-cluster deployment.apps/scylla-manager-cluster

### scylla main cluster
echo "Starting the scylla cluster..."
kubectl apply -f ./scylladb-full-manifests/cluster.yaml
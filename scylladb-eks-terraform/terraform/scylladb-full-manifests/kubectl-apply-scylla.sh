#!/bin/bash
set -euo pipefail

# check for a k8s resource to be present
function wait-for-object-creation {
    for i in {1..30}; do
        { kubectl -n "${1}" get "${2}" && break; } || sleep 1
    done
}

# check for the pod container to be in the 'Running' state
function wait-for-pod-ready {
    local namespace="$1"
    local deployment_name="$2"
    local timeout=300  # 5 minutes, adjust as needed
    local interval=5   # check every 5 seconds
    
    local start_time=$(date +%s)
    
    while true; do
        # Fetch the pod name based on the deployment name
        local pod_name=$(kubectl -n "$namespace" get pods -l app.kubernetes.io/name="$deployment_name" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
        
        if [[ -z "$pod_name" ]]; then
            echo "Pod with label app.kubernetes.io/name=${deployment_name} not found in namespace ${namespace}. Retrying..."
            sleep $interval
            continue
        fi
        
        # Get the pod's status based on the pod name
        local status=$(kubectl -n "$namespace" get pods "$pod_name" -o=jsonpath='{.status.phase}')
        
        if [[ "$status" == "Running" ]]; then
            # Check if all containers in the pod are ready
            local containers_ready=$(kubectl -n "$namespace" get pods "$pod_name" -o=jsonpath='{.status.containerStatuses[?(@.ready==true)].name}' | wc -w)
            local containers_total=$(kubectl -n "$namespace" get pods "$pod_name" -o=jsonpath='{.spec.containers[*].name}' | wc -w)
            
            if [[ "$containers_ready" -eq "$containers_total" ]]; then
                echo "Pod ${pod_name} and all of its containers are ready."
                break
            else
                echo "Pod ${pod_name} is running but only ${containers_ready}/${containers_total} containers are ready. Waiting..."
                sleep $interval
            fi
        elif [[ "$status" == "Failed" || "$status" == "Error" ]]; then
            echo "Error: Pod ${pod_name} has failed to start."
            exit 1
        else
            echo "Pod ${pod_name} status: ${status}. Waiting for it to be running and ready..."
            sleep $interval
        fi
        
        # Check for timeout
        local current_time=$(date +%s)
        local elapsed_time=$((current_time - start_time))
        
        if [[ $elapsed_time -ge $timeout ]]; then
            echo "Error: Timeout waiting for pod ${pod_name} to be ready."
            exit 1
        fi
    done
}

### cert manager
echo "Starting the cert manager..."
kubectl apply -f ./scylladb-full-manifests/common/cert-manager.yaml
kubectl wait --for condition=established --timeout=60s crd/certificates.cert-manager.io crd/issuers.cert-manager.io
wait-for-object-creation cert-manager deployment.apps/cert-manager-webhook
kubectl -n cert-manager rollout status --timeout=5m deployment.apps/cert-manager-webhook
sleep 10

### scylla operator
echo "Starting the scylla operator..."
kubectl apply -f ./scylladb-full-manifests/common/operator.yaml
kubectl wait --for condition=established crd/nodeconfigs.scylla.scylladb.com
kubectl wait --for condition=established crd/scyllaclusters.scylla.scylladb.com
wait-for-pod-ready scylla-operator webhook-server
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
wait-for-pod-ready scylla-manager scylla-manager

### scylla main cluster
echo "Starting the scylla cluster..."
kubectl apply -f ./scylladb-full-manifests/cluster.yaml
## This directory is for deploying scylla using the manifests from the scylla-operator/examples/ directory

### scylla-operator repo
https://github.com/scylladb/scylla-operator/tree/master/examples

### kubectl installations of scylladb and related resources after the cluster has been provisioned
```bash
kubectl-apply-scylla.sh
``` 

### kubectl cleanup of scylladb and related resources
```bash
kubectl-delete-scylla.sh
```

### troubleshoot
``` bash
kubectl describe pod <POD_OF_INTEREST_1> -n scylla > pod_1_description.txt

kubectl describe pod <POD_OF_INTEREST_2> -n scylla > pod_2_description.txt

diff pod_1_description.txt pod_2_description.txt
```

### logs
```bash
kubectl logs scylla-eu-central-1-eu-central-1a-0 -c scylla-manager-agent -n scylla-manager

kubectl logs scylla-eu-central-1-eu-central-1a-0 -c scylla -n scylla
```

### exec
```bash
kubectl exec -it scylla-manager-manager-dc-manager-rack-0 -n scylla-manager -- cqlsh

kubectl exec -it scylla-eu-central-1-eu-central-1a-0 -n scylla -- cqlsh
```


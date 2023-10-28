### provision the infrastructure
```bash
cd scylladb-eks-terraform/terraform/

terraform init

terraform apply -auto-approve
```

### upd kube config
```bash
aws eks update-kubeconfig --name scylla-dev --region eu-central-1

kubectl get nodes
```

### check kubelet config (optional)
```bash
ssh -i ~/.ssh/id_rsa ec2-user@<YOUR_PUBLIC_IPv4_DNS>

ps aux | grep kubelet

systemctl cat kubelet

cat /etc/kubernetes/kubelet/kubelet-config.json | grep cpu
```

### deploy the database
```bash
./scylladb-full-manifests/kubectl-apply-scylla.sh
``` 
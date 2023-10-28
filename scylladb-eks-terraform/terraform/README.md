### upd kube config
aws eks update-kubeconfig --name scylla-dev --region eu-central-1
kubectl get nodes

### check kubelet config
ssh -i ~/.ssh/id_rsa ec2-user@<YOUR_EC2_DNS_ADDRESS>
ps aux | grep kubelet
systemctl cat kubelet
cat /etc/kubernetes/kubelet/kubelet-config.json
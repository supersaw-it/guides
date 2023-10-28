### upd kube config
aws eks update-kubeconfig --name scylla-dev --region eu-central-1
kubectl get nodes

### check kubelet config
ssh -i ~/.ssh/id_rsa ec2-user@ec2-3-67-139-171.eu-central-1.compute.amazonaws.com
ps aux | grep kubelet
systemctl cat kubelet
cat /etc/kubernetes/kubelet/kubelet-config.json
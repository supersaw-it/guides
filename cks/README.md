# The Linux Foundation CKS Exam Preparation Materials
This sub-directory contains helpful tips, tricks, and commands to assist in preparing for the CKS (Certified Kubernetes Security Specialist) exam.

# Node Provisioning
Use the Terraform code in the *aws* folder to provision two EC2 instances that can serve as a master-worker pair for a sandbox Kubernetes cluster.

## SSH access
```bash
# configuration for EC2 instances; Ubuntu (!) machines
Host *amazonaws.com
  User ubuntu
  IdentityFile ~/.ssh/cks-machines.pem
  IdentitiesOnly yes
  CheckHostIP no

# configure individual hostnames for brevity
Host cks-master
  HostName <ec2-PUBLIC_IP.REGION>.compute.amazonaws.com # specific hostname for brevity
  User ec2-user
  IdentityFile ~/.ssh/cks-machines.pem
IdentitiesOnly yes

Host cks-worker
	HostName <ec2-PUBLIC_IP.REGION>.compute.amazonaws.com # specific hostname for brevity
	User ec2-user
	IdentityFile ~/.ssh/cks-machines.pem
	IdentitiesOnly yes
```

## Cluster setup
copy the *install_** scripts
```bash
scp cluster-setup/install_master.sh ubuntu@<EC2_MASTER_HOSTNAME>:~/
scp cluster-setup/install_worker.sh ubuntu@<EC2_WORKER_HOSTNAME>:~/
```

# The Linux Foundation CKS Exam Preparation Materials
This sub-directory contains helpful tips, tricks, and commands to assist in preparing for the CKS (Certified Kubernetes Security Specialist) exam.

# Node Provisioning
Use the Terraform code in the *aws* folder to provision two EC2 instances that can serve as a master-worker pair for a sandbox Kubernetes cluster.
```bash
# AWS api key/secret
export AWS_ACCESS_KEY_ID="YOUR_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET"

cd aws/

# change the "region" variable to suit your preference; default is 'eu-central-1'
# if you change the region, variable "ami_id" must also be adjsuted accordingly to your region
vim variables.tf 

terraform init
terraform validate
terraform plan

# create the cloud resources; Beware (!) that you must have already generated a Key pair 'cks-machines' via the AWS console: EC2 > Networking > Key pairs
terraform apply --auto-approve

# destroy the infrastructure when necessary
terraform destroy --auto-approve
```

## SSH access
```bash
vim ~/.ssh/config

# Add Hostnames declared below
# configuration for EC2 instances; Ubuntu (!) machines
Host *amazonaws.com
  User ubuntu
  IdentityFile ~/.ssh/cks-machines.pem # place your private key (generated via the AWS console) in the .ssh/ sub-directory
  IdentitiesOnly yes
  CheckHostIP no

# optional: configure individual hostnames for brevity
Host cks-master
  HostName <ec2-PUBLIC_IP.REGION>.compute.amazonaws.com # specific hostname for brevity, ! changes w/ every instance stop/start
  User ubuntu
  IdentityFile ~/.ssh/cks-machines.pem # place your private key (generated via the AWS console) in the .ssh/ sub-directory
  IdentitiesOnly yes

Host cks-worker
  HostName <ec2-PUBLIC_IP.REGION>.compute.amazonaws.com # specific hostname for brevity, ! changes w/ every instance stop/start
  User ubuntu
  IdentityFile ~/.ssh/cks-machines.pem
  IdentitiesOnly yes
```

## Cluster setup
copy & run the *install_** scripts
```bash
scp cluster-setup/install_master.sh ubuntu@<EC2_MASTER_HOSTNAME>:~/
scp cluster-setup/install_worker.sh ubuntu@<EC2_WORKER_HOSTNAME>:~/

# Master node
ssh <EC2_MASTER_HOSTNAME>
bash install_master.sh
# Worker node
ssh <EC2_WORKER_HOSTNAME>
bash install_worker.sh
```

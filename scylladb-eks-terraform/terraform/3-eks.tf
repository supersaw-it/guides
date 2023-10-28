module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.2"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id = module.vpc.vpc_id
  # subnet_ids = module.vpc.private_subnets
  subnet_ids = module.vpc.public_subnets

  enable_irsa = true

  eks_managed_node_group_defaults = {
    # # attach the EKS cluster primary SG to nodes for nodeconfig to successfully apply
    # # this is not needed, just add additional Node SG rules below
    # attach_cluster_primary_security_group = true  
    pre_bootstrap_user_data       = <<-EOT
      # Install jq
      yum install -y jq

      # Modify kubelet configuration using jq and an intermediate file
      jq '.cpuManagerPolicy = "static"' /etc/kubernetes/kubelet/kubelet-config.json > /etc/kubernetes/kubelet/kubelet-config.json.tmp && mv -f /etc/kubernetes/kubelet/kubelet-config.json.tmp /etc/kubernetes/kubelet/kubelet-config.json

      # Make sure to point kubelet to the modified configuration
      echo "KUBELET_EXTRA_ARGS=--config=/etc/kubernetes/kubelet/kubelet-config.json" >> /etc/sysconfig/kubelet
    EOT
  }

  eks_managed_node_groups = {
    scylla-pool = {

      desired_size = 2
      min_size     = 1
      max_size     = 2
      key_name     = aws_key_pair.eks_key.key_name

      labels = {
        "scylla.scylladb.com/node-type" = "scylla"
      }

      taints = [{
        key    = "role"
        value  = "scylla-clusters"
        effect = "NO_SCHEDULE"
      }]

      # instance_types = ["i4i.large"]
      # capacity_type  = "ON_DEMAND"
      ############
      # instance_types = ["m7gd.medium"]  # 1 vCPU is not a valid instance type for requested amiType AL2_x86_64
      # ami_type = "AL2_ARM_64"
      # capacity_type = "SPOT"
      ############
      instance_types = ["i4i.large"] # 2 vCPUs c5ad.large
      capacity_type  = "SPOT"
    }

    monitoring-pool = {

      desired_size = 1
      min_size     = 1
      max_size     = 1
      key_name     = aws_key_pair.eks_key.key_name

      labels = {
        pool = "monitoring-pool"
      }

      # instance_types = ["i3.large"]
      # capacity_type  = "ON_DEMAND"
      ############
      # instance_types = ["c7gd.medium"]  # 1 vCPUs is not a valid instance type for requested amiType AL2_x86_64
      # ami_type = "AL2_ARM_64"
      # capacity_type = "ON_DEMAND"
      ############
      instance_types = ["i3.large"] # 2 vCPUs
      capacity_type  = "ON_DEMAND"
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = module.eks_admins_iam_role.iam_role_arn
      username = module.eks_admins_iam_role.iam_role_name
      groups   = ["system:masters"]
    },
  ]

  node_security_group_additional_rules = {
    # Shard-aware Scylla client port
    ingress_allow_shard_aware_scylla_port = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 19042
      to_port                       = 19042
      source_cluster_security_group = true
      description                   = "Shard-aware Scylla client port"
    }

    # for nodeconfig to successfully apply, see https://github.com/scylladb/scylla-operator/issues/567
    ingress_allow_master_to_worker = {
      type                     = "ingress"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 9443
      source_security_group_id = module.eks.cluster_security_group_id
      description              = "Allow access from the master nodes to ports 443-9443 inside the private cluster"
    }
  }

  # # No need to attach this to the cluster SG, attaching the same rule to the worker nodes is enough
  # # see https://github.com/scylladb/scylla-operator/issues/567
  # cluster_security_group_additional_rules = {
  #   allow_access_to_port_9443 = {
  #     type                     = "ingress"
  #     from_port                = 443
  #     to_port                  = 9443
  #     protocol                 = "tcp"
  #     source_security_group_id = module.eks.cluster_security_group_id
  #     description              = "Allow access from the master nodes to ports 443-9443 inside the private cluster"
  #   }
  # }

  tags = {
    Environment = "staging"
  }
}

# https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2009
data "aws_eks_cluster" "default" {
  name       = module.eks.cluster_name
  depends_on = [module.vpc] # otherwise 'error reading EKS Cluster (scylla-dev): couldn't find resource'
}

data "aws_eks_cluster_auth" "default" {
  name       = module.eks.cluster_name
  depends_on = [module.vpc] # otherwise 'error reading EKS Cluster (scylla-dev): couldn't find resource'
}

# data "aws_eks_cluster" "default" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "default" {
#   name = module.eks.cluster_id
# }

resource "aws_key_pair" "eks_key" {
  key_name   = "eks-keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}

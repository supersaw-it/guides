# This module creates an IAM policy that provides permissions for EKS related actions.
module "allow_eks_access_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.30.0"

  name          = "allow-eks-access"
  create_policy = true

  # The policy itself allows for describing EKS clusters on all resources.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster", # The specific EKS action permitted
        ]
        Effect   = "Allow"
        Resource = "*" # Applicable to all resources
      },
    ]
  })
}

# This module creates an IAM role named "eks-admin". 
module "eks_admins_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.30.0"

  role_name         = "eks-admin"
  create_role       = true
  role_requires_mfa = false

  # Attach the policy we defined earlier to this role.
  custom_role_policy_arns = [module.allow_eks_access_iam_policy.arn]

  # Defines who is trusted to assume this role. 
  # In this case, the root user of the AWS account that owns the VPC.
  trusted_role_arns = [
    "arn:aws:iam::${module.vpc.vpc_owner_id}:root"
  ]
}

# Creates an IAM user named "user1". 
module "user1_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.30.0"

  name                          = "user1"
  create_iam_access_key         = false # Doesn't generate an AWS Access Key for this user.
  create_iam_user_login_profile = false # Doesn't create a login profile, meaning the user can't sign into the AWS Management Console.

  # If set to true, Terraform will destroy this user even if it has non-Terraform-managed IAM access keys, login profile or MFA devices.
  force_destroy = true
}

# Creates another IAM policy that allows the assumption of the "eks-admin" role.
module "allow_assume_eks_admins_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.30.0"

  name          = "allow-assume-eks-admin-iam-role"
  create_policy = true

  # The policy allows for assuming the previously created "eks-admin" role.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole", # Permission to assume a role
        ]
        Effect   = "Allow"
        Resource = module.eks_admins_iam_role.iam_role_arn # Specifically, the "eks-admin" role
      },
    ]
  })
}

# This module creates an IAM group named "eks-admin". 
module "eks_admins_iam_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.30.0"

  name                              = "eks-admin"
  attach_iam_self_management_policy = false # The group members can't manage their own IAM settings.
  create_group                      = true

  # Associates the "user1" IAM user with this group.
  group_users = [module.user1_iam_user.iam_user_name]

  # Attach the policy that allows assumption of the "eks-admin" role to this group.
  custom_group_policy_arns = [module.allow_assume_eks_admins_iam_policy.arn]
}

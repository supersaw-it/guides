variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "az1" {
  type    = string
  default = "eu-central-1a"
}

variable "az2" {
  type    = string
  default = "eu-central-1b"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "scylla-dev" # default value if the environment variable isn't set
}

# variable "kubelet_extra_args" {
#   description = "Extra arguments for kubelet"
#   type        = string
#   default     = "--cpu-manager-policy=static"
# }



# # use export AWS_ACCESS_KEY_ID= / provided as artifact in the pipeline
# variable "aws_access_key" {
#   type    = string
#   sensitive = true
# }


# # # use export AWS_SECRET_ACCESS_KEY= / provided as artifact in the pipeline
# variable "aws_secret_key" {
#   type    = string
#   sensitive = true
# }


# # Use the command line to inject this variable
# variable "personal_access_token" {
#   description = "personal access token github"
#   #  default = "replace_this_with_your_token"
# }
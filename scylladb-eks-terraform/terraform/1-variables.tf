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

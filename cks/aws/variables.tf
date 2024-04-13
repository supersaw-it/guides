variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "ami_id" {
  type    = string
  default = "ami-0a97c706034fef0b2" # 20.04 eu-central-1; https://cloud-images.ubuntu.com/locator/ec2/
}

variable "az1" {
  type    = string
  default = "eu-central-1a"
}

variable "az2" {
  type    = string
  default = "eu-central-1b"
}

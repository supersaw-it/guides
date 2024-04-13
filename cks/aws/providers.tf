provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Name    = "cks"
      purpose = "cks-sandbox-cluster"
    }
  }
}

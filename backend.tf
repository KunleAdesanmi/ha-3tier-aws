# This file is used to configure the backend for Terraform.
# It specifies the backend type and the configuration options for the backend.

# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket  = "ha-3tier-aws-backend"
    key     = "terraform/ha-3tier-aws/dev/terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}
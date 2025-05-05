# This is a Terraform configuration file that sets up a 3-tier architecture with high availability (HA) in AWS.
# It uses modules to create a VPC and subnets, and configures the AWS provider. The configuration is designed to be reusable and customizable through input variables.


# configure aws provider
provider "aws" {
  region  = var.region
  profile = "default"
}

# create a VPC
module "vpc" {
  source                       = "../modules/vpc"
  region                       = var.region
  project_name                 = var.project_name
  vpc_cidr                     = var.vpc_cidr
  public_subnet_az1_cidr       = var.public_subnet_az1_cidr
  public_subnet_az2_cidr       = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr  = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr  = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr
}

# This file is used to set the values for the variables defined in variable.tf
# The CIDR blocks for the VPC and subnets are defined here.
# These CIDR blocks should be chosen based on your network design and requirements.
# Ensure that the CIDR blocks do not overlap with each other or with any existing networks.

region                       = "us-east-1"
project_name                 = "ha-3tier-aws-dev"
vpc_cidr                     = "10.0.0.0/16"
public_subnet_az1_cidr       = "10.0.0.0/24"
public_subnet_az2_cidr       = "10.0.1.0/24"
private_app_subnet_az1_cidr  = "10.0.2.0/24"
private_app_subnet_az2_cidr  = "10.0.3.0/24"
private_data_subnet_az1_cidr = "10.0.4.0/24"
private_data_subnet_az2_cidr = "10.0.5.0/24"

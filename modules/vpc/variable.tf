# This file contains the variable definitions for the VPC module.
# It defines the input variables that can be used to customize the VPC configuration.
# The variables include the region, project name, VPC CIDR block, and CIDR blocks for public and private subnets in two availability zones.

variable "region" {}
variable "project_name" {}
variable "vpc_cidr" {}
variable "public_subnet_az1_cidr" {}
variable "public_subnet_az2_cidr" {}
variable "private_app_subnet_az1_cidr" {} 
variable "private_app_subnet_az2_cidr" {}  
variable "private_data_subnet_az1_cidr" {}
variable "private_data_subnet_az2_cidr" {}
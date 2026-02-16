# Outputs for the VPC module
# This file contains the output definitions for the VPC module.
# It defines the outputs that will be returned after the VPC module is applied.
# The outputs include the region, project name, VPC ID, public and private subnet IDs, and internet gateway ID.


output "region"          { value = var.region }
output "project_name"    { value = var.project_name } 
output "vpc_id"           { value = aws_vpc.vpc.id }
output "public_subnet_az1_id" { value = aws_subnet.public_subnet_az1.id }
output "public_subnet_az2_id" { value = aws_subnet.public_subnet_az2.id }
output "private_app_subnet_az1_id" { value = aws_subnet.private_app_subnet_az1.id }
output "private_app_subnet_az2_id" { value = aws_subnet.private_app_subnet_az2.id }
output "private_data_subnet_az1_id" { value = aws_subnet.private_data_subnet_az1.id }
output "private_data_subnet_az2_id" { value = aws_subnet.private_data_subnet_az2.id }
output "internet_gateway_id" { value = aws_internet_gateway.internet_gateway.id }

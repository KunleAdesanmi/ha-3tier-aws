
# This file contains the variable definitions for the 3-tier HA architecture module.
# It defines the input variables that can be used to customize the VPC configuration.

variable "region" {}
variable "project_name" {}
variable "vpc_cidr" {}
variable "public_subnet_az1_cidr" {}
variable "public_subnet_az2_cidr" {}
variable "private_app_subnet_az1_cidr" {}
variable "private_app_subnet_az2_cidr" {}
variable "private_data_subnet_az1_cidr" {}
variable "private_data_subnet_az2_cidr" {}



# Web Tier Variables
# These variables are used to configure the web tier of the 3-tier architecture.
variable "web_ami_id" {
  description = "AMI ID for the web tier instances"
  default     = "ami-084568db4383264d4" # Example AMI ID for the web tier
}

variable "web_instance_type" {
  description = "Instance type for the web tier"
  default     = "t3.micro"
}

variable "web_asg_max_size" {
  description = "Maximum size of the web tier ASG"
  default     = 3
}

variable "web_asg_min_size" {
  description = "Minimum size of the web tier ASG"
  default     = 1
}

variable "web_asg_desired_capacity" {
  description = "Desired capacity of the web tier ASG"
  default     = 2
}

# Application Tier Variables
# These variables are used to configure the application tier of the 3-tier architecture.
variable "app_ami_id" {
  description = "AMI ID for the application tier instances"
  default     = "ami-084568db4383264d4" # Example AMI ID for the application tier
}

variable "app_instance_type" {
  description = "Instance type for the application tier"
  default     = "t3.micro"
}

variable "app_asg_max_size" {
  description = "Maximum size of the application tier ASG"
  default     = 3
}

variable "app_asg_min_size" {
  description = "Minimum size of the application tier ASG"
  default     = 1
}

variable "app_asg_desired_capacity" {
  description = "Desired capacity of the application tier ASG"
  default     = 2
}


# ECS Cluster Variable
variable "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  default     = "3tier-ecs-cluster"
}

# ECS Service Variables
variable "ecs_desired_count" {
  description = "Number of desired tasks in the ECS service"
  default     = 2
}

# ECS Task Definition Variables
variable "ecs_task_cpu" {
  description = "Total CPU units for the ECS task definition"
  default     = "256"
}

variable "ecs_task_memory" {
  description = "Total memory (in MB) for the ECS task definition"
  default     = "512"
}

variable "app_container_image" {
  description = "Container image to use for the ECS task"
  default     = "nginx:latest" // Using a public image for testing
}

variable "ecs_container_cpu" {
  description = "CPU units allocated to the container"
  default     = 128
}

variable "ecs_container_memory" {
  description = "Memory (in MB) allocated to the container"
  default     = 256
}

variable "ecs_execution_role" {
  description = "ARN of the IAM role that the ECS task uses for execution"
  default     = "arn:aws:iam::563046585342:role/ecsTaskExecutionRole"
}

variable "ecs_service_security_group_id" {
  description = "Security group ID for the ECS service"
  default     = "" // Update with your security group or use an existing module output
}


# Aurora Database Variables

variable "db_username" {
  description = "Username for the Aurora DB cluster"
  type        = string
  default     = "admin" # Default username, should be changed in production
}

variable "db_password" {
  description = "Password for the Aurora DB cluster"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!" # Default password, should be changed in production
}

variable "db_name" {
  description = "Default database name to create in the Aurora cluster"
  type        = string
  default     = "mydatabase"
}

variable "db_instance_class" {
  description = "Instance type for the Aurora cluster instances"
  default     = "db.r5.large"
}

variable "db_reader_count" {
  description = "Number of Aurora reader instances"
  default     = 1
}

variable "db_security_group_id" {
  description = "Security group ID for the Aurora DB cluster"
  default     = "" // Update with your security group or use an existing module output
}

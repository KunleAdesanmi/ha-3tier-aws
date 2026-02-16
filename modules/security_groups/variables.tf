variable "project_name" {
  type        = string
  description = "Project name to prefix resource names"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the security groups will be created"
}
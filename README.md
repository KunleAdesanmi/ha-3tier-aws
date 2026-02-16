# AWS 3-Tier High Availability Architecture

Terraform configuration for deploying a production-ready, highly available 3-tier architecture on AWS. The infrastructure spans **two Availability Zones** to ensure fault tolerance and high availability across all tiers.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Architecture Diagram](#architecture-diagram)
- [Resources Provisioned](#resources-provisioned)
- [Directory Structure](#directory-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Configuration Reference](#configuration-reference)
- [CI/CD Pipeline](#cicd-pipeline)
- [Remote State](#remote-state)

---

## Architecture Overview

This project implements a classic 3-tier architecture pattern on AWS:

| Tier | Subnet Type | Purpose |
|------|-------------|---------|
| **Web** | Public | Handles incoming internet traffic via Auto Scaling Group |
| **Application** | Private | Runs business logic via EC2 ASG and ECS Fargate behind an ALB |
| **Data** | Private | Stores data in Aurora MySQL with writer/reader replication |

All tiers are deployed across **2 Availability Zones** for high availability, resulting in **6 subnets** total.

---

## Architecture Diagram

```
                         Internet
                            |
                     [ Internet Gateway ]
                            |
              +-------------+-------------+
              |                           |
     +--------+--------+        +--------+--------+
     | Public Subnet    |        | Public Subnet    |
     | AZ1              |        | AZ2              |
     | - Web ASG        |        | - Web ASG        |
     +--------+---------+        +--------+---------+
              |                           |
              +--------+     +------------+
                       |     |
                 [ Application Load Balancer ]
                       |     |
              +--------+-----+------------+
              |                           |
     +--------+---------+       +--------+---------+
     | Private App       |       | Private App       |
     | Subnet AZ1        |       | Subnet AZ2        |
     | - App ASG          |       | - App ASG          |
     | - ECS Fargate      |       | - ECS Fargate      |
     +--------+-----------+       +--------+-----------+
              |                           |
              +--------+     +------------+
                       |     |
              [ Aurora MySQL Cluster ]
              |                           |
     +--------+---------+       +--------+---------+
     | Private Data      |       | Private Data      |
     | Subnet AZ1        |       | Subnet AZ2        |
     | - Aurora Writer   |       | - Aurora Reader   |
     +-------------------+       +-------------------+
```

---

## Resources Provisioned

### Networking (VPC Module)

| Resource | Description |
|----------|-------------|
| VPC | Custom VPC with configurable CIDR block, DNS support and hostnames enabled |
| Public Subnets (x2) | One per AZ, auto-assign public IP enabled |
| Private App Subnets (x2) | One per AZ, for application workloads |
| Private Data Subnets (x2) | One per AZ, for database instances |
| Internet Gateway | Attached to VPC for public internet access |
| Public Route Table | Routes `0.0.0.0/0` to Internet Gateway, associated with both public subnets |

### Security Groups Module

| Security Group | Inbound Rules | Purpose |
|----------------|---------------|---------|
| ALB SG | TCP 80 from `0.0.0.0/0` | Allows HTTP traffic to the load balancer |
| ECS SG | TCP 80 from ALB SG only | Allows traffic from ALB to ECS tasks |
| DB SG | TCP 3306 from ECS SG only | Allows MySQL connections from app tier only |

### Web Tier

| Resource | Description |
|----------|-------------|
| Launch Template | Configurable AMI, instance type, and tags |
| Auto Scaling Group | Min/max/desired capacity across both public subnets |

### Application Tier

| Resource | Description |
|----------|-------------|
| Launch Template | Configurable AMI, instance type, and tags |
| Auto Scaling Group | Min/max/desired capacity across both private app subnets |
| Application Load Balancer | Internet-facing, deployed in public subnets |
| Target Group | HTTP on port 80 with health checks (`/` endpoint, 30s interval) |
| Listener | HTTP port 80, forwards to target group |
| ECS Cluster | Fargate cluster for containerized workloads |
| ECS Task Definition | Fargate-compatible, `awsvpc` network mode, configurable CPU/memory |
| ECS Service | Runs desired task count, integrated with ALB target group |

### Data Tier

| Resource | Description |
|----------|-------------|
| DB Subnet Group | Spans both private data subnets |
| Aurora MySQL Cluster | Provisioned engine mode, configurable credentials and database name |
| Writer Instance | Single writer in private data subnet |
| Reader Instance(s) | Configurable count of read replicas |

---

## Directory Structure

```
ha-3tier-aws/
├── main.tf                          # Root config: provider, modules, all resources
├── variable.tf                      # Input variable definitions with defaults
├── terraform.tfvars                 # Variable values (CIDR blocks, project name)
├── backend.tf                       # S3 remote state backend configuration
├── .gitignore                       # Terraform-specific ignores
├── CHANGELOG.md                     # Project change history
├── CLAUDE.md                        # AI assistant project context
├── README.md                        # This file
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf                  # VPC, subnets, IGW, route tables
│   │   ├── output.tf                # Exports: VPC ID, subnet IDs, IGW ID
│   │   └── variable.tf              # Module input variables
│   │
│   └── security_groups/
│       ├── main.tf                  # ALB, ECS, and DB security groups
│       ├── outputs.tf               # Exports: security group IDs
│       └── variables.tf             # Module input variables
│
└── .github/
    └── workflows/
        └── ci.yaml                  # CI/CD pipeline (lint -> plan -> apply)
```

---

## Prerequisites

- **Terraform** >= 1.5.0
- **AWS CLI** configured with credentials (or environment variables)
- **S3 bucket** for remote state: `ha-3tier-aws-backend-563046585342`
- **IAM role** for ECS task execution: `ecsTaskExecutionRole`

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/KunleAdesanmi/ha-3tier-aws.git
cd ha-3tier-aws
```

### 2. Configure variables

Edit `terraform.tfvars` with your desired CIDR blocks and project name:

```hcl
region                       = "us-east-1"
project_name                 = "ha-3tier-aws-dev"
vpc_cidr                     = "10.0.0.0/16"
public_subnet_az1_cidr       = "10.0.1.0/24"
public_subnet_az2_cidr       = "10.0.2.0/24"
private_app_subnet_az1_cidr  = "10.0.3.0/24"
private_app_subnet_az2_cidr  = "10.0.4.0/24"
private_data_subnet_az1_cidr = "10.0.5.0/24"
private_data_subnet_az2_cidr = "10.0.6.0/24"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Preview changes

```bash
terraform plan
```

### 5. Deploy

```bash
terraform apply
```

### 6. Destroy (when done)

```bash
terraform destroy
```

---

## Configuration Reference

### Networking Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `region` | AWS region to deploy in | Yes |
| `project_name` | Prefix for all resource names and tags | Yes |
| `vpc_cidr` | CIDR block for the VPC | Yes |
| `public_subnet_az1_cidr` | CIDR for public subnet in AZ1 | Yes |
| `public_subnet_az2_cidr` | CIDR for public subnet in AZ2 | Yes |
| `private_app_subnet_az1_cidr` | CIDR for private app subnet in AZ1 | Yes |
| `private_app_subnet_az2_cidr` | CIDR for private app subnet in AZ2 | Yes |
| `private_data_subnet_az1_cidr` | CIDR for private data subnet in AZ1 | Yes |
| `private_data_subnet_az2_cidr` | CIDR for private data subnet in AZ2 | Yes |

### Web Tier Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `web_ami_id` | AMI ID for web tier instances | `ami-084568db4383264d4` |
| `web_instance_type` | EC2 instance type | `t3.micro` |
| `web_asg_max_size` | Maximum ASG size | `3` |
| `web_asg_min_size` | Minimum ASG size | `1` |
| `web_asg_desired_capacity` | Desired ASG capacity | `2` |

### Application Tier Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `app_ami_id` | AMI ID for app tier instances | `ami-084568db4383264d4` |
| `app_instance_type` | EC2 instance type | `t3.micro` |
| `app_asg_max_size` | Maximum ASG size | `3` |
| `app_asg_min_size` | Minimum ASG size | `1` |
| `app_asg_desired_capacity` | Desired ASG capacity | `2` |

### ECS Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ecs_cluster_name` | Name of the ECS cluster | `3tier-ecs-cluster` |
| `ecs_desired_count` | Number of Fargate tasks | `2` |
| `ecs_task_cpu` | CPU units for task definition | `256` |
| `ecs_task_memory` | Memory (MB) for task definition | `512` |
| `app_container_image` | Container image for ECS task | `nginx:latest` |
| `ecs_container_cpu` | CPU units for container | `128` |
| `ecs_container_memory` | Memory (MB) for container | `256` |
| `ecs_execution_role` | IAM role ARN for ECS execution | `arn:aws:iam::563046585342:role/ecsTaskExecutionRole` |
| `ecs_service_security_group_id` | Security group ID for ECS service | `""` |

### Database Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `db_username` | Aurora master username | `admin` |
| `db_password` | Aurora master password (sensitive) | `ChangeMe123!` |
| `db_name` | Default database name | `mydatabase` |
| `db_instance_class` | Aurora instance class | `db.r5.large` |
| `db_reader_count` | Number of Aurora read replicas | `1` |
| `db_security_group_id` | Security group ID for Aurora cluster | `""` |

---

## CI/CD Pipeline

The project uses **GitHub Actions** for continuous integration and deployment.

### Workflow: `AWS 3 Tier HA Dev Deployment Pipeline`

Triggers on every `push` to any branch.

```
push -> [lint] -> [plan] -> [apply] (master only)
```

| Job | Trigger | Steps |
|-----|---------|-------|
| **lint** | Every push | `terraform init` -> `terraform fmt` -> `terraform validate` |
| **plan** | After lint passes | `terraform init` -> `terraform plan` -> upload plan artifact |
| **apply** | After plan passes, `master` branch only | `terraform init` -> download plan artifact -> `terraform apply` |

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | IAM access key with permissions to manage AWS resources |
| `AWS_SECRET_ACCESS_KEY` | Corresponding secret access key |

---

## Remote State

Terraform state is stored remotely in S3 for team collaboration and state locking:

| Setting | Value |
|---------|-------|
| **Backend** | S3 |
| **Bucket** | `ha-3tier-aws-backend-563046585342` |
| **Key** | `terraform/ha-3tier-aws/dev/terraform.tfstate` |
| **Region** | `us-east-1` |

# AWS 3-Tier High Availability Architecture

Terraform configuration for deploying a production-ready, highly available 3-tier architecture on AWS spanning multiple Availability Zones.

## Architecture

This project provisions the following infrastructure:

### Web Tier (Public)
- Auto Scaling Group with configurable min/max/desired capacity
- Launch template with customizable AMI and instance type
- Deployed across **2 public subnets** in separate AZs

### Application Tier (Private)
- Auto Scaling Group for EC2-based workloads
- ECS Fargate cluster for containerized services
- Application Load Balancer (ALB) with health checks
- Deployed across **2 private application subnets** in separate AZs

### Data Tier (Private)
- Aurora MySQL cluster with writer and reader instances
- DB subnet group spanning **2 private data subnets** in separate AZs
- Configurable reader replica count

### Networking
- Custom VPC with configurable CIDR blocks
- 6 subnets: 2 public, 2 private app, 2 private data
- Internet Gateway with route table associations
- Security groups module for ALB, ECS, and database access control

## Directory Structure

```
TerraformModules/
├── 3-tierHA/
│   ├── main.tf              # Root configuration: providers, modules, and all resources
│   ├── variable.tf          # Input variable definitions
│   ├── terraform.tfvars     # Variable values (CIDR blocks, project settings)
│   └── backend.tf           # S3 remote state backend configuration
└── modules/
    ├── vpc/
    │   ├── main.tf          # VPC, subnets, internet gateway, route tables
    │   ├── output.tf        # VPC and subnet ID outputs
    │   └── variable.tf      # VPC module variables
    └── security_groups/
        └── main.tf          # Security group definitions
```

## Prerequisites

- Terraform installed
- AWS CLI configured with a `default` profile
- S3 bucket for remote state (`ha-3tier-aws-backend`)

## Usage

```bash
cd 3-tierHA

# Initialize Terraform and download modules/providers
terraform init

# Preview changes
terraform plan

# Deploy the infrastructure
terraform apply
```

## Configuration

Key variables can be customized in `terraform.tfvars` or passed via CLI:

| Variable | Description | Default |
|---|---|---|
| `region` | AWS region | - |
| `project_name` | Prefix for all resource names | - |
| `vpc_cidr` | VPC CIDR block | - |
| `web_instance_type` | Web tier instance type | `t3.micro` |
| `app_instance_type` | App tier instance type | `t3.micro` |
| `ecs_desired_count` | Number of ECS Fargate tasks | `2` |
| `db_instance_class` | Aurora instance class | `db.r5.large` |
| `db_reader_count` | Number of Aurora read replicas | `1` |

## Remote State

Terraform state is stored in S3:
- **Bucket:** `ha-3tier-aws-backend`
- **Key:** `terraform/ha-3tier-aws/dev/terraform.tfstate`
- **Region:** `us-east-1`

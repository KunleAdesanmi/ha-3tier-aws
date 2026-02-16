# Project Context

## Overview
AWS 3-Tier High Availability Architecture deployed with Terraform. The infrastructure spans two Availability Zones in us-east-1.

## AWS Account
- **Account ID:** 563046585342
- **Region:** us-east-1
- **S3 State Bucket:** ha-3tier-aws-backend-563046585342

## Architecture
- **Web Tier:** Auto Scaling Group in public subnets
- **App Tier:** Auto Scaling Group + ECS Fargate in private app subnets, fronted by an ALB
- **Data Tier:** Aurora MySQL cluster (writer + reader) in private data subnets

## Repository Structure
- `main.tf` — Root config: provider, VPC module, security groups module, ASGs, ALB, ECS, Aurora
- `variable.tf` — All input variable definitions
- `terraform.tfvars` — Variable values (CIDR blocks, project name)
- `backend.tf` — S3 remote state config
- `modules/vpc/` — VPC, subnets, IGW, route tables
- `modules/security_groups/` — ALB, ECS, and DB security groups
- `.github/workflows/ci.yaml` — CI/CD pipeline (lint → plan → apply on master)

## CI/CD Pipeline
- Triggers on every push to any branch
- **lint:** terraform init, fmt, validate
- **plan:** terraform init, plan (uploads plan artifact)
- **apply:** only runs on `master` branch pushes; downloads plan artifact and applies
- GitHub secrets required: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

## Important Notes
- Do NOT hardcode `profile = "default"` in provider or backend blocks — breaks CI
- Module sources use `./modules/` (local to repo), not `../modules/` (parent directory)
- Always update CHANGELOG.md when making changes to this project

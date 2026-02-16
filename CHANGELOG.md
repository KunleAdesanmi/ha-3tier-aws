# Changelog

All notable changes to this project will be documented in this file.

## [2026-02-16]

### Added
- `.gitignore` file with standard Terraform exclusions (.terraform/, *.tfstate, *.tfvars, etc.)
- `.terraform.lock.hcl` committed to lock provider versions
- `modules/vpc/` — VPC module copied into repo (previously referenced from parent directory)
- `modules/security_groups/` — Security groups module copied into repo
- ECS task execution IAM role (`ecsTaskExecutionRole`) created in new AWS account (563046585342)
- S3 bucket `ha-3tier-aws-backend-563046585342` created for Terraform remote state

### Changed
- `README.md` — Rewritten with comprehensive project documentation covering architecture, directory structure, prerequisites, usage, configuration, and remote state
- `backend.tf` — Updated S3 backend bucket name from `ha-3tier-aws-backend` to `ha-3tier-aws-backend-563046585342`
- `backend.tf` — Removed hardcoded `profile = "default"` for CI compatibility
- `main.tf` — Removed hardcoded `profile = "default"` from AWS provider for CI compatibility
- `main.tf` — Updated module source paths from `../modules/vpc` and `../modules/security_groups` to `./modules/vpc` and `./modules/security_groups`
- `variable.tf` — Updated `ecs_execution_role` default ARN to new account role (`arn:aws:iam::563046585342:role/ecsTaskExecutionRole`)
- `.github/workflows/ci.yaml` — Fixed working directory paths (removed invalid `../` and `root` references)
- `.github/workflows/ci.yaml` — Changed apply job trigger from `refs/heads/main` to `refs/heads/master`
- `.github/workflows/ci.yaml` — Fixed terraform apply plan file path (`tfplan/tfplan`)
- `.github/workflows/ci.yaml` — Upgraded GitHub Actions versions:
  - `actions/checkout` v3 → v4
  - `aws-actions/configure-aws-credentials` v1 → v4
  - `hashicorp/setup-terraform` v2 → v3
  - `actions/download-artifact` v3 → v4

### Infrastructure
- Migrated project from deleted AWS account to new account (563046585342)
- Updated GitHub repository secrets with new AWS credentials
- CI pipeline (lint → plan → apply) now fully functional on master branch

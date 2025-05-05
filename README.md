# Terraform Modules for AWS 3-Tier HA Architecture

This repository contains Terraform modules and configurations to provision a highly available (HA) 3-tier architecture on AWS.

## Overview

The repository is organized into two main components:

1. **VPC Module** (`modules/vpc`):
   - Creates a Virtual Private Cloud (VPC) with configurable CIDR blocks.
   - Provisions public and private subnets across two Availability Zones.
   - Sets up an Internet Gateway and associated route tables for public subnets.
   - Outputs key information for the created resources, such as VPC ID, subnet IDs, and Internet Gateway ID.

2. **3-Tier HA Module** (`3-tierHA`):
   - Configures the AWS provider.
   - Integrates the VPC module to build the network infrastructure.
   - Uses input variables from `variable.tf` and `terraform.tfvars` to customize the infrastructure.
   - Stores Terraform state remotely using an S3 backend (configured in `backend.tf`).

## Directory Structure

```
TerraformModules
├── 3-tierHA
│   ├── backend.tf              # Configures remote state storage in S3
│   ├── main.tf                # Main configuration file that uses the VPC module
│   ├── terraform.tfvars       # Variable definitions with CIDR blocks and project details
│   └── variable.tf            # Variable definitions for the 3-tier HA configuration
└── modules
    └── vpc
        ├── main.tf            # Provisions the VPC, subnets, internet gateway and associations
        ├── output.tf          # Outputs of the VPC module
        └── variable.tf        # Variable definitions for the VPC configuration
```

## How to Use

1. **Configure Your Environment:**
   - Ensure you have Terraform installed.
   - Set up AWS credentials and configure the `default` profile if necessary.

2. **Initialize Terraform:**
   - In the `3-tierHA` directory, run:
     ```
     terraform init
     ```

3. **Plan the Deployment:**
   - Generate an execution plan to verify the resources to be created:
     ```
     terraform plan
     ```

4. **Apply the Configuration:**
   - Apply the Terraform configuration to create the resources in AWS:
     ```
     terraform apply
     ```

5. **Review Outputs:**
   - After a successful apply, Terraform outputs important resource identifiers (e.g., VPC ID, subnet IDs, and Internet Gateway ID).

## Customization

- Update variable values in `terraform.tfvars` to meet your network design requirements.
- Modify the module code in `modules/vpc` as needed for custom tagging, CIDR configurations, or additional resource provisioning.

## License

This repository is provided as-is under the terms of the applicable open source license.

---

For more details on the individual resources and configurations, check the source code files directly or refer to the Terraform documentation.

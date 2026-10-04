# lesson-5

Terraform project for AWS in `us-west-2`.

It creates:

- an S3 bucket and a DynamoDB table for the Terraform state
- a VPC with public and private subnets
- an ECR repository for Docker images

The state file is stored in S3 (`lesson-5/terraform.tfstate`), not in git.

## Project structure

```
lesson-5/
├── main.tf          # connects the modules
├── backend.tf       # S3 backend for the state
├── outputs.tf       # values printed after apply
├── modules/
│   ├── s3-backend/  # S3 bucket + DynamoDB lock table
│   ├── vpc/         # network
│   └── ecr/         # Docker image repository
└── README.md
```

## Modules

**s3-backend** creates an S3 bucket for the state file. Versioning is on, so old versions of the state are kept. It also creates a DynamoDB table named `terraform-locks`. Terraform uses this table so two people cannot change the state at the same time.

**vpc** creates a VPC `10.0.0.0/16` with 3 public subnets and 3 private subnets. Public subnets use an Internet Gateway. Private subnets use one NAT Gateway. Route tables send the traffic the right way.

**ecr** creates a repository for Docker images. Images are scanned on push. The account can push and pull images. After apply, Terraform prints the repository URL.

## Commands

Run these from the `lesson-5` folder:

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

- `terraform init` downloads the AWS provider and connects to the S3 backend.
- `terraform plan` shows what will be created or changed. It does not change AWS.
- `terraform apply` creates the resources.
- `terraform destroy` deletes the resources, including the state bucket and the lock table.

`destroy` also deletes the S3 bucket and DynamoDB table that keep the state. To create them again, comment out the backend in `backend.tf`, run `terraform apply`, put the backend back, then run `terraform init -reconfigure`.

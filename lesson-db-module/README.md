# lesson-db-module

Terraform project for AWS in `us-west-2`.

It creates:

- an S3 bucket and a DynamoDB table for the Terraform state
- a VPC with public and private subnets
- a PostgreSQL 17.11 database on `db.t3.micro` in the private subnets

The database comes from `modules/rds`. Set `use_aurora = false` for a normal RDS instance, or `use_aurora = true` for an Aurora cluster. The module also creates a DB subnet group, a security group, and a parameter group.

## Commands

From the repo root, copy the password file and set `db_password`. Do not commit `terraform.tfvars`.

```bash
cp lesson-db-module/terraform.tfvars.example lesson-db-module/terraform.tfvars
cd lesson-db-module
terraform init
terraform apply
terraform destroy
```

`db_endpoint` is the database address after apply.

`destroy` also deletes the S3 bucket and DynamoDB table that keep the state. To create them again, comment out the backend in `backend.tf`, run `terraform apply`, put the backend back, then run `terraform init -migrate-state`.

## Module example

```hcl
module "rds" {
  source = "./modules/rds"

  name                       = "myapp-db"
  use_aurora                 = false
  engine                     = "postgres"
  engine_version             = "17.11"
  parameter_group_family_rds = "postgres17"
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  db_name                    = "myapp"
  username                   = "postgres"
  password                   = var.db_password
  subnet_private_ids         = module.vpc.private_subnets
  subnet_public_ids          = module.vpc.public_subnets
  publicly_accessible        = false
  vpc_id                     = module.vpc.vpc_id
  multi_az                   = false
  backup_retention_period    = 7

  parameters = {
    max_connections = "200"
    log_statement   = "ddl"
    work_mem        = "4096"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

## Change the database

Normal PostgreSQL, as in `main.tf`:

```hcl
use_aurora                 = false
engine                     = "postgres"
engine_version             = "17.11"
parameter_group_family_rds = "postgres17"
instance_class             = "db.t3.micro"
```

Normal MySQL. Drop `log_statement` and `work_mem`. Those settings are for PostgreSQL only.

```hcl
use_aurora                 = false
engine                     = "mysql"
engine_version             = "8.4.11"
parameter_group_family_rds = "mysql8.4"
instance_class             = "db.t3.micro"
parameters = {
  max_connections = "200"
}
```

Aurora PostgreSQL. Do not use `db.t3.micro`. The first instance is the writer. Extra instances are readers.

```hcl
use_aurora                    = true
engine_cluster                = "aurora-postgresql"
engine_version_cluster        = "17.11"
parameter_group_family_aurora = "aurora-postgresql17"
instance_class                = "db.t3.medium"
aurora_instance_count         = 2
```

`instance_class` sets the size. `multi_az = true` adds a standby for normal RDS. For Aurora, set `aurora_instance_count` above 1. `publicly_accessible = false` uses private subnets. `true` uses public subnets.

## Variables

| Variable | Type | Default | What it does |
| --- | --- | --- | --- |
| `name` | string | — | Name of the instance or cluster |
| `use_aurora` | bool | `false` | `true` creates Aurora, `false` creates normal RDS |
| `engine` | string | `postgres` | Engine for normal RDS: `postgres` or `mysql` |
| `engine_version` | string | `17.11` | Version for normal RDS |
| `parameter_group_family_rds` | string | `postgres17` | Parameter group family for normal RDS |
| `engine_cluster` | string | `aurora-postgresql` | Aurora engine |
| `engine_version_cluster` | string | `17.11` | Aurora version |
| `parameter_group_family_aurora` | string | `aurora-postgresql17` | Parameter group family for Aurora |
| `aurora_instance_count` | number | `2` | How many Aurora instances. The first one is the writer |
| `instance_class` | string | `db.t3.micro` | Instance size. Aurora needs `db.t3.medium` or larger |
| `allocated_storage` | number | `20` | Disk size in GB. Used only by normal RDS |
| `db_name` | string | — | Database name |
| `username` | string | — | Admin user |
| `password` | string, sensitive | — | Admin password |
| `vpc_id` | string | — | VPC for the security group |
| `subnet_private_ids` | list(string) | — | Private subnets |
| `subnet_public_ids` | list(string) | — | Public subnets |
| `publicly_accessible` | bool | `false` | Public access, and which subnets to use |
| `multi_az` | bool | `false` | Standby instance for normal RDS |
| `backup_retention_period` | number | `7` | How many days to keep backups |
| `parameters` | map(string) | `max_connections`, `log_statement`, `work_mem` | Settings in the parameter group |
| `parameter_apply_method` | string | `pending-reboot` | `pending-reboot` or `immediate` |
| `allowed_cidr_blocks` | list(string) | `["0.0.0.0/0"]` | Who can connect. Narrow this outside a lab |
| `port` | number | `null` | Port. Empty means 5432 for PostgreSQL and 3306 for MySQL |
| `skip_final_snapshot` | bool | `true` | Skip the final snapshot on destroy |
| `storage_encrypted` | bool | `true` | Encrypt the disk |
| `tags` | map(string) | `{}` | Tags for the resources |

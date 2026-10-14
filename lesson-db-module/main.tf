provider "aws" {
  region = "us-west-2"
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "terraform-state-bucket-andr-928001001-lessondb"
  table_name  = "terraform-locks-lessondb"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.2.0.0/16"
  public_subnets     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  private_subnets    = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "lesson-db-vpc"
  cluster_name       = "lesson-db"
}

module "rds" {
  source = "./modules/rds"

  name                       = "lesson-db"
  use_aurora                 = false
  aurora_instance_count      = 2
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
  backup_retention_period    = 1

  parameters = {
    max_connections = "200"
    log_statement   = "ddl"
    work_mem        = "4096"
  }

  tags = {
    Environment = "dev"
    Project     = "lesson-db-module"
  }
}

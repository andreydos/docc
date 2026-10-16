provider "aws" {
  region = "us-west-2"
}

locals {
  cluster_name = "final-eks"
  vpc_cidr     = "10.3.0.0/16"
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "terraform-state-bucket-andr-928001001-final"
  table_name  = "terraform-locks-final"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = local.vpc_cidr
  public_subnets     = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
  private_subnets    = ["10.3.4.0/24", "10.3.5.0/24", "10.3.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "final"
  cluster_name       = local.cluster_name
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "final-django"
  scan_on_push = true
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = local.cluster_name
  cluster_version    = "1.35"
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets
  desired_size       = 3
  min_size           = 3
  max_size           = 3
  instance_types     = ["t3.small"]
}

module "rds" {
  source = "./modules/rds"

  name                       = "final-db"
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
  backup_retention_period    = 1
  allowed_cidr_blocks        = [local.vpc_cidr]

  parameters = {
    max_connections = "200"
    log_statement   = "ddl"
    work_mem        = "4096"
  }

  tags = {
    Environment = "dev"
    Project     = "final"
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--region", "us-west-2", "--cluster-name", local.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--region", "us-west-2", "--cluster-name", local.cluster_name]
    }
  }
}

resource "kubernetes_secret_v1" "django_rds" {
  metadata {
    name      = "django-rds"
    namespace = "default"
  }

  data = {
    POSTGRES_DB       = "myapp"
    POSTGRES_NAME     = "myapp"
    POSTGRES_USER     = "postgres"
    POSTGRES_PASSWORD = var.db_password
    POSTGRES_HOST     = module.rds.endpoint
    POSTGRES_PORT     = tostring(module.rds.port)
  }

  depends_on = [module.eks]
}

module "jenkins" {
  source             = "./modules/jenkins"
  cluster_name       = module.eks.cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider_url  = module.eks.oidc_provider_url
  ecr_repository_arn = module.ecr.repository_arn
  github_username    = var.github_username
  github_token       = var.github_token
  git_repo_url       = var.git_repo_url
  git_revision       = var.git_revision

  depends_on = [module.eks]
}

module "argo_cd" {
  source          = "./modules/argo_cd"
  github_username = var.github_username
  github_token    = var.github_token
  git_repo_url    = var.git_repo_url
  git_revision    = var.git_revision
  chart_path      = "Project/charts/django-app"

  depends_on = [module.eks, kubernetes_secret_v1.django_rds]
}

module "monitoring" {
  source = "./modules/monitoring"

  depends_on = [module.eks]
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.2"

  depends_on = [module.eks]
}

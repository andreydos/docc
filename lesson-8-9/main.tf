provider "aws" {
  region = "us-west-2"
}

locals {
  cluster_name = "lesson-8-9-eks"
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "terraform-state-bucket-andr-928001001-lesson89"
  table_name  = "terraform-locks-lesson89"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.1.0.0/16"
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnets    = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "lesson-8-9-vpc"
  cluster_name       = local.cluster_name
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-8-9-django"
  scan_on_push = true
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = local.cluster_name
  cluster_version    = "1.35"
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets
  desired_size       = 2
  min_size           = 2
  max_size           = 3
  instance_types     = ["t3.small"]
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--region", "us-west-2", "--cluster-name", local.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--region", "us-west-2", "--cluster-name", local.cluster_name]
    }
  }
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
  source          = "./modules/argo-cd"
  github_username = var.github_username
  github_token    = var.github_token
  git_repo_url    = var.git_repo_url
  git_revision    = var.git_revision
  chart_path      = "lesson-8-9/charts/django-app"

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

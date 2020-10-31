terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "contrast-project2"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets      = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  enable_dns_hostnames = true

  enable_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.18"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.medium"
      asg_desired_capacity = 1
    }
  ]
}

resource "random_pet" "bucket" {
  length = 2
}

resource "aws_s3_bucket" "vulns_bucket" {
  bucket = "project2-vulns-${random_pet.bucket.id}"
}

resource "aws_s3_bucket_object" "vulns_file" {
  bucket = aws_s3_bucket.vulns_bucket.id
  key    = "example.json"
  source = "../example.json"
}

resource "aws_ecr_repository" "vulns_app" {
  name = "vulns-app"

  provisioner "local-exec" {
    command = <<EOF
    aws ecr get-login-password | docker login --username AWS --password-stdin ${aws_ecr_repository.vulns_app.repository_url}
    docker tag vulns-app ${aws_ecr_repository.vulns_app.repository_url}
    docker push ${aws_ecr_repository.vulns_app.repository_url}
    EOF
  }
}


resource "aws_ecr_repository" "proxy" {
  name = "proxy"

  provisioner "local-exec" {
    command = <<EOF
    aws ecr get-login-password | docker login --username AWS --password-stdin ${aws_ecr_repository.proxy.repository_url}
    docker tag proxy ${aws_ecr_repository.proxy.repository_url}
    docker push ${aws_ecr_repository.proxy.repository_url}
    EOF
  }
}

module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.1.0"

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = var.region
  k8s_cluster_name = data.aws_eks_cluster.cluster.name
}

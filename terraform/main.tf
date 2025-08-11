terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  backend "s3" {
    bucket         = "spectra-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "Spectra"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"
  
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs
}

module "database" {
  source = "./modules/database"
  
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  engine_version  = var.db_engine_version
  instance_class  = var.db_instance_class
  database_name   = var.database_name
  master_username = var.db_master_username
}

module "eks" {
  source = "./modules/eks"
  
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  cluster_name    = "${var.project_name}-${var.environment}"
  node_group_name = "${var.project_name}-node-group-${var.environment}"
  instance_types  = var.eks_instance_types
  min_size        = var.eks_min_size
  max_size        = var.eks_max_size
  desired_size    = var.eks_desired_size
}

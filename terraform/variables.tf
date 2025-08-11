variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "spectra"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "db_engine_version" {
  description = "The version of the database engine"
  type        = string
  default     = "14.5"
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.small"
}

variable "database_name" {
  description = "The name of the database"
  type        = string
  default     = "spectra"
}

variable "db_master_username" {
  description = "The master username for the database"
  type        = string
  default     = "spectra"
}

variable "eks_instance_types" {
  description = "Instance types for the EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
  default     = 1
}

variable "eks_max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
  default     = 5
}

variable "eks_desired_size" {
  description = "Desired size of the EKS node group"
  type        = number
  default     = 3
}

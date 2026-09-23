variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name used to identify project resources"
  type        = string
  default     = "three-tier"
}

variable "instance_type" {
  description = "EC2 instance type for web and application servers"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "RDS PostgreSQL instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "key_pair_name" {
  description = "AWS EC2 key pair name"
  type        = string
  default     = "wtf_key3"
}
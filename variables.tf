# AWS Region
variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

# VPC CIDR Block (used only in dev workspace)
variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

# Public Subnet CIDR Block (used only in dev workspace)
variable "public_subnet_cidr" {
  type    = string
  default = "10.1.1.0/24"
}

# EC2 Instance Type
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

# AMI ID
variable "ami_id" {
  type    = string
  default = "ami-02521d90e7410d9f0"
}

# EC2 Key Pair Name (must match existing key in AWS)
variable "key_name" {
  type    = string
  default = "debasishkey"
}

# Project Name (required input)
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# S3 Logs Bucket Name (shared across workspaces)
variable "logs_bucket_name" {
  description = "Name of the S3 bucket to store logs"
  type        = string
  default     = "techeazy-logs-debasish-87"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.1.1.0/24"
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-02521d90e7410d9f0"  # Ubuntu 22.04 LTS (ap-south-1)
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "debasishkey"
}

# App & Deployment
variable "environment" {
  description = "Environment label (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "stage" {
  description = "Deployment stage (e.g., dev, prod)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Logging
variable "logs_bucket_name" {
  description = "Name of the S3 bucket to store logs and health indicators"
  type        = string
}

# GitHub Access
variable "github_pat" {
  description = "GitHub Personal Access Token for accessing private repositories"
  type        = string
  default     = ""  # Required only for prod (can be empty in dev)
}

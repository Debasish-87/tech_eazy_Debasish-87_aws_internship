variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.1.1.0/24"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-02521d90e7410d9f0"
}

variable "key_name" {
  type    = string
  default = "debasishkey"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}


variable "logs_bucket_name" {
  type = string
  description = "Name of the S3 bucket to store logs"
}


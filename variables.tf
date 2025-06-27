variable "aws_region" {
  description = "The AWS region where resources will be deployed (e.g., us-east-1)"
  type        = string
}

variable "instance_type" {
  default = "t2.micro"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID used to launch the EC2 instance"
  type        = string
}

variable "stage" {
  description = "Stage identifier to differentiate environments (e.g., dev, test, prod)"
  type        = string
}
variable "log_s3_bucket_name" {
  description = "Name of the S3 bucket to store logs"
  type        = string
}
variable"shutdown_after_minutes"{
  description = "Number of minutes after which EC2 instance should Auto-shutdown"
  type = number
}

variable "github_token" {
  description = "Github PAT for private repo access(prod only)"
  type=string
  default = ""
  sensitive = true
}
variable "github_repo_url" {
  description = "Github repo URL for dev and prod"
  type=string
}

variable "github_private_repo" {
  description = "Github private repo URL for prod"
  default = ""
  type=string
}

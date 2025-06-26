aws_region         = "ap-south-1"
vpc_cidr           = "10.1.0.0/16"
public_subnet_cidr = "10.1.1.0/24"
instance_type      = "t2.micro"
ami_id             = "ami-02521d90e7410d9f0"
key_name           = "debasishkey"

#  Central S3 bucket (used in both dev & prod)
logs_bucket_name = "techeazy-logs-debasish-87"

# Tagging purpose
project_name = "techeazy-devops"

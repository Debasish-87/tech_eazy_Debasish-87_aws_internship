provider "aws" {
  region = var.aws_region
}

locals {
  environment = terraform.workspace
  is_dev      = terraform.workspace == "dev" || terraform.workspace == "default"
}

################### VPC ###################
resource "aws_vpc" "custom_vpc" {
  count                = local.is_dev ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "dev-vpc"
    Environment = local.environment
    Project     = var.project_name
  }
}

data "aws_vpc" "existing_vpc" {
  count = local.is_dev ? 0 : 1
  filter {
    name   = "tag:Name"
    values = ["dev-vpc"]
  }
}

################### Subnet ###################
resource "aws_subnet" "public_subnet" {
  count                   = local.is_dev ? 1 : 0
  vpc_id                  = aws_vpc.custom_vpc[0].id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name        = "dev-public-subnet"
    Environment = local.environment
    Project     = var.project_name
  }
}

data "aws_subnet" "existing_subnet" {
  count = local.is_dev ? 0 : 1
  filter {
    name   = "tag:Name"
    values = ["dev-public-subnet"]
  }
}

################### Internet Gateway + Routing ###################
resource "aws_internet_gateway" "igw" {
  count  = local.is_dev ? 1 : 0
  vpc_id = aws_vpc.custom_vpc[0].id

  tags = {
    Name        = "dev-igw"
    Environment = local.environment
    Project     = var.project_name
  }
}

resource "aws_route_table" "public_rt" {
  count  = local.is_dev ? 1 : 0
  vpc_id = aws_vpc.custom_vpc[0].id

  tags = {
    Name        = "dev-public-rt"
    Environment = local.environment
    Project     = var.project_name
  }
}

resource "aws_route" "internet_access" {
  count                  = local.is_dev ? 1 : 0
  route_table_id         = aws_route_table.public_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = local.is_dev ? 1 : 0
  subnet_id      = aws_subnet.public_subnet[0].id
  route_table_id = aws_route_table.public_rt[0].id
}

################### Security Group ###################
resource "aws_security_group" "web_security_group" {
  name        = "${local.environment}-web-security-group"
  description = "Allow HTTP and SSH"
  vpc_id      = local.is_dev ? aws_vpc.custom_vpc[0].id : data.aws_vpc.existing_vpc[0].id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow All Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.environment}-web-security-group"
    Environment = local.environment
    Project     = var.project_name
  }
}

################### EC2 Instance ###################
resource "aws_instance" "app" {
  count = local.is_dev ? 1 : 0

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.web_security_group.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile[0].name

  user_data = templatefile("${path.module}/user_data.sh", {
    BUCKET_NAME = var.logs_bucket_name
    ENVIRONMENT = local.environment
    DATE        = timestamp()
    GITHUB_PAT  = var.github_pat
  })

  tags = {
    Name        = "${local.environment}-app-instance"
    Environment = local.environment
    Project     = var.project_name
  }
}

################### Prod Log Trigger ###################
resource "null_resource" "prod_log_trigger" {
  count = local.is_dev ? 0 : 1

  provisioner "local-exec" {
    command = <<EOT
    #!/bin/bash
    set -euo pipefail

    IP="${data.aws_instance.dev_instance[0].public_ip}"
    KEY_PATH="./debasishkey.pem"
    SCRIPT_PATH="./prod_logs.sh"

    if [ ! -f "$SCRIPT_PATH" ]; then
      echo " ERROR: Script file not found at $SCRIPT_PATH"
      exit 1
    fi

    echo " Copying and executing prod_logs.sh on $IP..."

    # Upload prod_logs.sh to EC2
    scp -i "$KEY_PATH" -o StrictHostKeyChecking=no "$SCRIPT_PATH" ubuntu@$IP:/tmp/prod_logs.sh

    # Make it executable and run it
    ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$IP "chmod +x /tmp/prod_logs.sh && sudo /tmp/prod_logs.sh"

    echo " Script uploaded and executed on $IP"
    EOT

    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    always_run = timestamp()
  }
}

################### Variables ###################
variable "github_pat" {
  description = "GitHub PAT for private repo access (used in prod)"
  type        = string
  sensitive   = true
  default     = "" # safe for dev environment
}

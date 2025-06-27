provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "allow_http_and_ssh" {
  name        = "allow_http_and_ssh"
  description = "Allow HTTP traffic and SSH traffic on port 80 and 22"
  vpc_id = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name= "Appserver-sg"
  }
}

locals {
  repo_url = var.stage == "prod" && var.github_token != "" && var.github_private_repo != "" ? "https://${var.github_token}@github.com/${var.github_private_repo}.git" :var.github_repo_url
}

resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_http_and_ssh.id]
  iam_instance_profile = var.stage == "dev" ? aws_iam_instance_profile.ec2_instance_profile_b[0].name : data.aws_iam_instance_profile.ec2_instance_profile_b[0].name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/scripts/user_data.sh.tftpl", {
    log_s3_bucket_name=var.log_s3_bucket_name
    shutdown_after_minutes = var.shutdown_after_minutes
    stage= var.stage
    TIMESTAMP= timestamp()
    REPO_URL= local.repo_url
})

  tags = {
    Name  = "AppServer-${var.stage}"
    Stage = var.stage
  }
}

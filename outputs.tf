# VPC ID (created in dev or fetched in prod)
output "vpc_id" {
  description = "VPC ID (created in dev, reused in prod)"
  value       = local.is_dev ? aws_vpc.custom_vpc[0].id : data.aws_vpc.existing_vpc[0].id
}

# Subnet ID (created in dev or fetched in prod)
output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = local.is_dev ? aws_subnet.public_subnet[0].id : data.aws_subnet.existing_subnet[0].id
}

output "instance_public_ip" {
  value = local.is_dev ? aws_instance.app[0].public_ip : data.aws_instance.dev_instance[0].public_ip
}

output "instance_private_ip" {
  value = local.is_dev ? aws_instance.app[0].private_ip : data.aws_instance.dev_instance[0].private_ip
}

output "instance_id" {
  value = local.is_dev ? aws_instance.app[0].id : data.aws_instance.dev_instance[0].id
}

output "prod_log_trigger_status" {
  value = " prod_logs.sh uploaded and executed in ${terraform.workspace}"
}

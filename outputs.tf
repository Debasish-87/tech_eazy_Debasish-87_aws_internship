output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.custom_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.app.id
}

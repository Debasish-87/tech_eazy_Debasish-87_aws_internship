output "app_ec2_public_ip" {
  description = "Public IP of the EC2 instance running the Java app"
  value       = aws_instance.app_server.public_ip
}
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "web_subnet_ids" {
  description = "Public web subnet IDs"
  value       = [aws_subnet.web_public_az1.id, aws_subnet.web_public_az2.id]
}

output "app_subnet_ids" {
  description = "Private app subnet IDs"
  value       = [aws_subnet.app_private_az1.id, aws_subnet.app_private_az2.id]
}

output "db_subnet_ids" {
  description = "Private DB subnet IDs"
  value       = [aws_subnet.db_private_az1.id, aws_subnet.db_private_az2.id]
}

output "alb_dns_name" {
  description = "Public DNS name of the application load balancer"
  value       = aws_lb.web.dns_name
}

output "web_instance_public_ips" {
  description = "Public IPs of web instances"
  value       = [aws_instance.web_server_az1.public_ip, aws_instance.web_server_az2.public_ip]
}

output "app_instance_private_ips" {
  description = "Private IPs of app instances"
  value       = [aws_instance.app_server_az1.private_ip, aws_instance.app_server_az2.private_ip]
}

output "rds_endpoint" {
  description = "RDS endpoint for application connections"
  value       = aws_db_instance.main.address
}

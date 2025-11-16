# Terraform Outputs
# Displays public IPs and important information

output "vpc_id" {
  description = "Default VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "Public subnet ID where instances are placed"
  value       = module.vpc.public_subnet_id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "web_server_instance_id" {
  description = "Web Server Instance ID"
  value       = module.ec2.web_server_instance_id
}

output "web_server_public_ip" {
  description = "Web Server Public IP Address"
  value       = module.ec2.web_server_public_ip
}

output "web_server_private_ip" {
  description = "Web Server Private IP Address"
  value       = module.ec2.web_server_private_ip
}

output "db_server_instance_id" {
  description = "MongoDB Database Server Instance ID"
  value       = module.ec2.db_server_instance_id
}

output "db_server_public_ip" {
  description = "MongoDB Database Server Public IP Address"
  value       = module.ec2.db_server_public_ip
}

output "db_server_private_ip" {
  description = "MongoDB Database Server Private IP Address"
  value       = module.ec2.db_server_private_ip
}

output "web_server_security_group_id" {
  description = "Web Server Security Group ID"
  value       = module.ec2.web_server_security_group_id
}

output "db_server_security_group_id" {
  description = "Database Server Security Group ID"
  value       = module.ec2.db_server_security_group_id
}

output "web_server_iam_role_arn" {
  description = "Web Server IAM Role ARN"
  value       = module.iam.web_server_iam_role_arn
}

output "db_server_iam_role_arn" {
  description = "Database Server IAM Role ARN"
  value       = module.iam.db_server_iam_role_arn
}


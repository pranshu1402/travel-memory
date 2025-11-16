# EC2 Module - Web Server and MongoDB Database Server

# Web Server EC2 Instance
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.web_server.id]

  iam_instance_profile = var.iam_instance_profile_web != "" ? var.iam_instance_profile_web : null
  key_name            = var.key_name != "" ? var.key_name : null

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              EOF

  tags = merge(
    var.tags,
    {
      Name = "MERN-Web-Server"
      Type = "WebServer"
    }
  )

  depends_on = [ aws_security_group.web_server ]
}

# MongoDB Database Server EC2 Instance
resource "aws_instance" "db_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.db_server.id]

  iam_instance_profile = var.iam_instance_profile_db != "" ? var.iam_instance_profile_db : null
  key_name            = var.key_name != "" ? var.key_name : null

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              EOF

  tags = merge(
    var.tags,
    {
      Name = "MongoDB-Database-Server"
      Type = "DatabaseServer"
    }
  )

  depends_on = [ aws_security_group.db_server ]
}

# Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-03c1f788292172a4e"]
  }
}

# Outputs
output "web_server_instance_id" {
  description = "Web server instance ID"
  value       = aws_instance.web_server.id
}

output "web_server_public_ip" {
  description = "Web server public IP address"
  value       = aws_instance.web_server.public_ip
}

output "web_server_private_ip" {
  description = "Web server private IP address"
  value       = aws_instance.web_server.private_ip
}

output "db_server_instance_id" {
  description = "Database server instance ID"
  value       = aws_instance.db_server.id
}

output "db_server_public_ip" {
  description = "Database server public IP address"
  value       = aws_instance.db_server.public_ip
}

output "db_server_private_ip" {
  description = "Database server private IP address"
  value       = aws_instance.db_server.private_ip
}


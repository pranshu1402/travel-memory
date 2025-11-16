# Security Groups for Web Server and Database Server

# Web Server Security Group
resource "aws_security_group" "web_server" {
  name        = "web-server-sg"
  description = "Security group for MERN web server - allows HTTP, HTTPS, and SSH"
  vpc_id      = var.vpc_id

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "Web-Server-Security-Group"
    }
  )
}

# Database Server Security Group
resource "aws_security_group" "db_server" {
  name        = "db-server-sg"
  description = "Security group for MongoDB database server - allows SSH and MongoDB port from web server"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MongoDB port - only from web server security group
  ingress {
    description     = "MongoDB"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server.id]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "DB-Server-Security-Group"
    }
  )
}

# Pass Security Group IDs to outputs
output "web_server_security_group_id" {
  description = "Web server security group ID"
  value       = aws_security_group.web_server.id
}

output "db_server_security_group_id" {
  description = "Database server security group ID"
  value       = aws_security_group.db_server.id
}


# IAM Module - Monitoring and Log Access Roles

# CloudWatch Agent Server Policy
data "aws_iam_policy" "cloudwatch_agent_server_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy" "cloudwatch_full_access" {
  arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

data "aws_iam_policy_document" "ec2_instance_connect" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "web_server_role" {
  name = "WebServerMonitoringRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "Web-Server-Monitoring-Role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "web_server_cloudwatch_agent" {
  role       = aws_iam_role.web_server_role.name
  policy_arn = data.aws_iam_policy.cloudwatch_agent_server_policy.arn
}

resource "aws_iam_role_policy_attachment" "web_server_cloudwatch_full" {
  role       = aws_iam_role.web_server_role.name
  policy_arn = data.aws_iam_policy.cloudwatch_full_access.arn
}

resource "aws_iam_role" "db_server_role" {
  name = "DBServerMonitoringRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "DB-Server-Monitoring-Role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "db_server_cloudwatch_agent" {
  role       = aws_iam_role.db_server_role.name
  policy_arn = data.aws_iam_policy.cloudwatch_agent_server_policy.arn
}

resource "aws_iam_role_policy_attachment" "db_server_cloudwatch_full" {
  role       = aws_iam_role.db_server_role.name
  policy_arn = data.aws_iam_policy.cloudwatch_full_access.arn
}

resource "aws_iam_instance_profile" "web_server" {
  name = "WebServerInstanceProfile"
  role = aws_iam_role.web_server_role.name
}

resource "aws_iam_instance_profile" "db_server" {
  name = "DBServerInstanceProfile"
  role = aws_iam_role.db_server_role.name
}

# Outputs
output "web_server_iam_role_name" {
  description = "Web server IAM role name"
  value       = aws_iam_role.web_server_role.name
}

output "web_server_iam_role_arn" {
  description = "Web server IAM role ARN"
  value       = aws_iam_role.web_server_role.arn
}

output "web_server_instance_profile_name" {
  description = "Web server IAM instance profile name"
  value       = aws_iam_instance_profile.web_server.name
}

output "db_server_iam_role_name" {
  description = "Database server IAM role name"
  value       = aws_iam_role.db_server_role.name
}

output "db_server_iam_role_arn" {
  description = "Database server IAM role ARN"
  value       = aws_iam_role.db_server_role.arn
}

output "db_server_instance_profile_name" {
  description = "Database server IAM instance profile name"
  value       = aws_iam_instance_profile.db_server.name
}


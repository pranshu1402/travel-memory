# Root Level Variables

variable "instance_type" {
  description = "EC2 instance type for web server and database server"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS Key Pair name for SSH access (optional)"
  type        = string
  default     = "pranshu_k"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}


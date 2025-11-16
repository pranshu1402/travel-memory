# EC2 Module Variables

variable "vpc_id" {
  description = "VPC ID where instances will be created"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID where instances will be placed"
  type        = string
}

# Security groups are defined within EC2 module, no need for variables

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS Key Pair name for SSH access"
  type        = string
  default     = ""
}

variable "iam_instance_profile_web" {
  description = "IAM instance profile name for web server"
  type        = string
  default     = ""
}

variable "iam_instance_profile_db" {
  description = "IAM instance profile name for database server"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}


# VPC Module - Default VPC Configuration
# Uses Default VPC, configures Internet Gateway and Route Table

# Fetch Default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch Default VPC subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Fetch Default VPC public subnet
data "aws_subnet" "public" {
  count = length(data.aws_subnets.default.ids)
  
  id = data.aws_subnets.default.ids[count.index]
}

# Check Internet Gateway (already exists in Default VPC)
data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Fetch Default Route Table
data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
  
  filter {
    name   = "association.main"
    values = ["true"]
  }
}

# Outputs
output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "Default VPC subnet IDs"
  value       = data.aws_subnets.default.ids
}

output "public_subnet_id" {
  description = "First public subnet ID"
  value       = length(data.aws_subnets.default.ids) > 0 ? data.aws_subnets.default.ids[0] : null
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = data.aws_internet_gateway.default.id
}

output "route_table_id" {
  description = "Default route table ID"
  value       = data.aws_route_table.default.id
}


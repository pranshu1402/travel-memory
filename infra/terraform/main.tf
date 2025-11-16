# Main Terraform Configuration
# Integrates all modules

# Common tags
locals {
  common_tags = {
    Project     = "TravelMemory"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  tags = local.common_tags
}

# EC2 Module - Web Server and Database Server
module "ec2" {
  source = "./modules/ec2"

  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id

  iam_instance_profile_web = module.iam.web_server_instance_profile_name
  iam_instance_profile_db  = module.iam.db_server_instance_profile_name

  instance_type = var.instance_type
  key_name      = var.key_name

  tags = local.common_tags

  depends_on = [
    module.vpc,
    module.iam
  ]
}


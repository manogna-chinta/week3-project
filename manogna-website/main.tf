# configure aws provider
provider "aws" {
  region  = var.region
  profile = "default"
}

# create vpc
module "vpc" {
  source                           = "../modules/vpc"
  region                           = var.region
  project_name                     = var.project_name
  vpc_cidr                         = var.vpc_cidr
  public_subnet_az1_cidr           = var.public_subnet_az1_cidr
  public_subnet_az2_cidr           = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr      = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr      = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr     = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr     = var.private_data_subnet_az2_cidr
}

# create nat gateways
module "nat_gateway" {
  source                     = "../modules/nat-gateway"
  public_subnet_az1_id       = module.vpc.public_subnet_az1_id
  internet_gateway           = module.vpc.internet_gateway
  public_subnet_az2_id       = module.vpc.public_subnet_az2_id
  vpc_id                     = module.vpc.vpc_id
  private_app_subnet_az1_id  = module.vpc.private_app_subnet_az1_id
  private_app_subnet_az2_id  = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
}
#create security group
module "security-group" {
  source = "../modules/security-group"
  vpc_id = module.vpc.vpc_id
}
# creating RDS instance

module "rds" {
  source                        = "../modules/rds"
  database_security_group       = module.security-group.database_security_group_id
  private_data_subnet_az1_id    = module.private_data_subnet_az2_id
  private_data_subnet_az2_id    = module.private_data_subnet_az2_id 
  database_username    = var.database_username
  database_password    = var.database_password
}

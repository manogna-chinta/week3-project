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
# creating Key for instances
module "key" {
  source = "../modules/key"
}
# Creating Application Load balancer
module "alb" {
  source         = "../modules/alb"
  project_name   = module.vpc.project_name
  alb_security_group_id      = module.security-group.alb_security_group_id
  public_subnet_az1_id = module.vpc.public_subnet_az1_id
  public_subnet_az2_id = module.vpc.public_subnet_az2_id
  vpc_id         = module.vpc.vpc_id
}

module "asg" {
  source                     = "../modules/asg"
  project_name               = module.vpc.project_name
  key_name                   = module.key.key_name
  client_security_group_id   = module.security-group.client_security_group_id
  private_app_subnet_az1_id  = module.vpc.private_app_subnet_az1_id
  private_app_subnet_az2_id  = module.vpc.private_app_subnet_az2_id
  tg_arn         = module.alb.tg_arn

}

# create cloudfront distribution 
module "cloudfront" {
  source = "../modules/cloudfront"
  certificate_domain_name = var.certificate_domain_name
  alb_domain_name = module.alb.alb_dns_name
  additional_domain_name = var.additional_domain_name
  project_name = module.vpc.project_name
}
# Add record in route 53 hosted zone

module "route53" {
  source = "../modules/route53"
  cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.cloudfront.cloudfront_hosted_zone_id

}

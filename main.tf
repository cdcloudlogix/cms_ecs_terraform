module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-testing"
  cidr = "10.2.0.0/16"

  azs              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets  = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  database_subnets = ["10.2.21.0/24", "10.2.22.0/24"]
  public_subnets   = ["10.2.101.0/24", "10.2.102.0/24", "10.2.103.0/24"]

  create_vpc                   = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  enable_vpn_gateway           = false
  one_nat_gateway_per_az       = false

  tags = {
    Terraform   = "true"
    Environment = "testing"
  }
}

module "security_groups" {
  source = "./modules/security_groups"

  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source = "./modules/rds"

  sg_cms_rds_id = module.security_groups.sg_cms_rds_id
  subnet_db_cms_name = module.vpc.database_subnet_group
  rds_db_name = var.rds_db_name
  rds_username = var.rds_username
  rds_password = var.rds_password
}

module "ecs" {
  source = "./modules/ecs"

  region = var.region
  vpc_id = module.vpc.vpc_id
  sg_cms_ecs_id = module.security_groups.sg_cms_ecs_id
  sg_cms_elb_id = module.security_groups.sg_cms_elb_id
  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  rds_host = module.rds.db_instance_cms_endpoint
  rds_db_name = var.rds_db_name
  rds_username = var.rds_username
  rds_password = var.rds_password
}

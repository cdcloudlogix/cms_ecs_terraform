variable "region" {}
variable "rds_host" {}
variable "rds_db_name" {}
variable "rds_username" {}
variable "rds_password" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "sg_cms_ecs_id" {}
variable "sg_cms_elb_id" {}
variable "vpc_id" {}

provider "aws" {
  region = "eu-west-1"
}

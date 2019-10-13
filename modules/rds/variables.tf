variable "rds_instance" {
  default = "db.t3.small"
}
variable "sg_cms_rds_id" {}
variable "subnet_db_cms_name" {}
variable "rds_db_name" {}
variable "rds_username" {}
variable "rds_password" {}

provider "aws" {
  region = "eu-west-1"
}

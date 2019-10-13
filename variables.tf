provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "cms-terraform-state-repository"
    key    = "testing/cms-terraform"
    region = "eu-west-1"
  }
}

variable "region" {
  default = "eu-west-1"
}

variable "rds_db_name" {
  default = "cmsmysql"
}

variable "rds_username" {
  default = "mysqluser"
}

variable "rds_password" {
  default = "mysqlpass"
}

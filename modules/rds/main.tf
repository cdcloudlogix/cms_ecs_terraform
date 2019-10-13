resource "aws_db_instance" "cms" {
    name                   = var.rds_db_name
    identifier             = "cms"
    username               = var.rds_username
    password               = var.rds_password
    port                   = "3306"
    engine                 = "mysql"
    engine_version         = "5.7"
    instance_class         = var.rds_instance
    allocated_storage      = "10"
    storage_encrypted      = false
    skip_final_snapshot    = true
    vpc_security_group_ids = [var.sg_cms_rds_id]
    db_subnet_group_name   = var.subnet_db_cms_name
    parameter_group_name   = "default.mysql5.7"
    storage_type           = "gp2"
    publicly_accessible    = false
}

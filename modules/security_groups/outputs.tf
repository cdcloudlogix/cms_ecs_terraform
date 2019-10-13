output "sg_cms_elb_id" {
  value = aws_security_group.cms_alb.id
}

output "sg_cms_ecs_id" {
  value = aws_security_group.cms_ecs.id
}

output "sg_cms_rds_id" {
  value = aws_security_group.cms_rds.id
}

# Service role allowing AWS to manage resources required for ECS
resource "aws_iam_service_linked_role" "ecs_service" {
  aws_service_name = "ecs.amazonaws.com"
}

# IAM Role for publishing events
resource "aws_ecs_cluster" "cms" {
  name = "cms-cluster"
}

resource "aws_cloudwatch_log_group" "cms" {
  name = "/ecs/cms"
}

data "aws_iam_policy_document" "cms_log_publishing" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]
    resources = ["arn:aws:logs:${var.region}:*:log-group:/ecs/cms:*"]
  }
}

resource "aws_iam_policy" "cms_log_publishing" {
  name        = "cms-log-pub"
  path        = "/"
  description = "Allow publishing to cloudwach"

  policy = data.aws_iam_policy_document.cms_log_publishing.json
}

data "aws_iam_policy_document" "cms_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cms_role" {
  name               = "cms-role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.cms_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "cms_role_log_publishing" {
  role = aws_iam_role.cms_role.name
  policy_arn = aws_iam_policy.cms_log_publishing.arn
}

# ECS Task definition
resource "aws_ecs_task_definition" "cms" {
  family                   = "cms"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.cms_role.arn

  container_definitions = <<DEFINITION
    [
      {
        "image": "wordpress",
        "name": "cms",
        "networkMode": "awsvpc",
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80
          }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/ecs/cms",
            "awslogs-region": "${var.region}",
            "awslogs-stream-prefix": "ecs"
          }
        },
        "environment": [
          {
            "name": "WORDPRESS_DB_HOST",
            "value": "${var.rds_host}"
          },
          {
            "name": "WORDPRESS_DB_USER",
            "value": "${var.rds_username}"
          },
          {
            "name": "WORDPRESS_DB_PASSWORD",
            "value": "${var.rds_password}"
          },
          {
            "name": "WORDPRESS_DB_NAME",
            "value": "${var.rds_db_name}"
          }
        ]
      }
    ]
DEFINITION
}

# ECS Service
resource "aws_ecs_service" "cms" {
  name            = "cms-service"
  cluster         = aws_ecs_cluster.cms.id
  task_definition = aws_ecs_task_definition.cms.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip  = true
    security_groups   = [var.sg_cms_ecs_id]
    subnets           = var.private_subnets
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.cms.id
    container_name   = "cms"
    container_port   = "80"
  }
}

# ALB Service
resource "aws_alb" "cms" {
  name            = "cms-alb"
  subnets         = var.public_subnets
  security_groups = [var.sg_cms_elb_id]
}

resource "aws_alb_target_group" "cms" {
  name        = "cms-alb"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path = "/"
    matcher = "302"
  }
}

resource "aws_alb_listener" "cms" {
  load_balancer_arn = aws_alb.cms.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.cms.id
    type             = "forward"
  }
}

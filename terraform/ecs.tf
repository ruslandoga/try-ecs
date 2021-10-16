resource "aws_ecs_cluster" "ecs_cluster" {
  name = "test_cluster"
}

# TODO EC2 SPOT
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "test_task_another_eh2"
  task_role_arn            = aws_iam_role.ecs_role.arn
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  memory                   = 2048
  cpu                      = 1024

  # TODO host
  network_mode = "awsvpc"

  container_definitions = <<-EOF
  [
    {
      "cpu": 0,
      "image": "${var.docker_image}",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log_group.name}",
          "awslogs-region": "eu-north-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "hostPort": 4000,
          "protocol": "tcp",
          "containerPort": 4000
        },
        {
          "hostPort": 4369,
          "protocol": "tcp",
          "containerPort": 4369
        },
        {
          "hostPort": 4370,
          "protocol": "tcp",
          "containerPort": 4370
        }
      ],
      "environment": [
        {"name": "WEB_HOST", "value": "${aws_lb.load_balancer.dns_name}"},
        {"name": "SECRET_KEY_BASE", "value": "7xXiSaNsw/5DHJrzT7YMArinaSAJG521GOncKdmOECUIljE6WHHGKCqyqOXmREqw"},
        {"name": "RELEASE_COOKIE", "value": "kka+STG7DXGVweA24KXsKkb+oBVMg7RHd9t5i3KrkUD0e1GBYr2VLO1xG7p+IxFY"}
      ],
      "mountPoints": [],
      "volumesFrom": [],
      "essential": true,
      "links": [],
      "name": "ecs_test"
    }
  ]
  EOF
}

resource "aws_ecs_service" "service" {
  name    = "test_service"
  cluster = aws_ecs_cluster.ecs_cluster.id

  task_definition        = "arn:aws:ecs:eu-north-1:${data.aws_caller_identity.current.account_id}:task-definition/${aws_ecs_task_definition.task_definition.family}:${aws_ecs_task_definition.task_definition.revision}"
  desired_count          = 2
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    security_groups  = [aws_security_group.security_group.id]
    subnets          = data.aws_subnet.default_subnet.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = "ecs_test"
    container_port   = "4000"
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.service_discovery.arn
    container_name = "ecs_test"
  }
}

resource "aws_security_group" "security_group" {
  name        = "test_app_ecs"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP/S Traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

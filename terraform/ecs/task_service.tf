resource "aws_ecs_task_definition" "megapool" {
  family                   = "megapool"
  requires_compatibilities = ["EC2"]

  # TODO soft
  memory       = 256
  network_mode = "host"

  # port mappings are really not used since network=host
  # but they seem to be required by aws_ecs_service.service_registries
  container_definitions = <<-EOF
  [
    {
      "image": "${var.docker_image}",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log_group.name}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "hostPort": ${var.container_http_port},
          "protocol": "tcp",
          "containerPort": ${var.container_http_port}
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
        {"name": "PORT", "value": "${var.container_http_port}"},
        {"name": "WEB_HOST", "value": "${var.web_host}"},
        {"name": "SECRET_KEY_BASE", "value": "${var.phx_secret_key_base}"},
        {"name": "RELEASE_COOKIE", "value": "${var.erl_release_cookie}"},
        {"name": "EC2_REGIONS", "value": "${concat(",", var.discovery_regions)}"},
        {"name": "PRIMARY_HOST_PREFIX", "value": "${var.primary_host_prefix}"}
      ],
      "essential": true,
      "name": "${"elixir-test" /* TODO */}"
    }
  ]
  EOF
}

resource "aws_ecs_service" "megapool" {
  name        = "megapool"
  cluster     = aws_ecs_cluster.megapool.id
  launch_type = "EC2"

  task_definition     = aws_ecs_task_definition.megapool.arn
  scheduling_strategy = "DAEMON"

  # deployment_maximum_percent         = 150
  deployment_minimum_healthy_percent = 50
  # desired_count = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.megapool.arn
    container_name   = "elixir-test"
    container_port   = var.container_http_port
  }

  # TODO create before delete?

  # service_registries {
  #   registry_arn   = aws_service_discovery_service.megapool.arn
  #   container_name = "elixir-test"
  #   # just pointing to epmd port, not really used though
  #   container_port = 4369
  # }
}

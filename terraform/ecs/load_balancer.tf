// # target group = where to route the requests (ecs:4000)
resource "aws_lb_target_group" "megapool" {
  name     = "megapool"
  port     = var.container_http_port
  protocol = "HTTP"
  # TODO http2
  # protocol_version = "HTTP2" (needs TLS)
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path = "/health"
    port = var.container_http_port
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = "true"
    cookie_duration = "3600"
  }
}

resource "aws_lb_listener" "megapool_http" {
  load_balancer_arn = aws_lb.megapool.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "megapool_https" {
  load_balancer_arn = aws_lb.megapool.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.lb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.megapool.arn
  }
}

# general lb config
resource "aws_lb" "megapool" {
  name               = "megapool"
  internal           = false
  load_balancer_type = "application"

  security_groups = concat([aws_security_group.megapool_lb.id], var.extra_lb_security_groups)
  subnets         = var.lb_subnets

  # access_logs {
  #   bucket  = module.s3_bucket_for_logs.s3_bucket_id
  #   prefix  = "megapool-lb"
  #   enabled = true
  # }

  # enable_deletion_protection = true
}

# module "s3_bucket_for_logs" {
#   source = "terraform-aws-modules/s3-bucket/aws"

#   bucket = "my-s3-bucket-for-log-hahaha-so-crazys"
#   acl    = "log-delivery-write"

#   # Allow deletion of non-empty bucket
#   force_destroy = true

#   attach_elb_log_delivery_policy = true # Required for ALB logs
#   attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs
# }

# firewall on load balancer
resource "aws_security_group" "megapool_lb" {
  name        = "lb_security_group"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

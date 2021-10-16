# target group = where to route the requests (ecs:4000)
resource "aws_lb_target_group" "lb_target_group" {
  name        = "ecs-test-tg"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path = "/health"
    port = "4000"
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = "true"
    cookie_duration = "3600"
  }
}

# from where to route the requests (http:80)
resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  # TODO
  # uncomment following lines if using SSL
  # ssl_policy = "ELBSecurityPolicy-2016-08"
  # certificate_arn = "" # the ARN a valid cert from Certificate Manager

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

# general lb config
resource "aws_lb" "load_balancer" {
  name               = "test-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_security_group.id]
  subnets            = data.aws_subnet.default_subnet.*.id

  # enable_deletion_protection = true
}

# firewall on load balancer
resource "aws_security_group" "lb_security_group" {
  name        = "lb_security_group"
  description = "Allow all outbound traffic and http inbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "dns" {
  value = aws_lb.load_balancer.dns_name
}

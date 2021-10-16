resource "aws_ecs_cluster" "megapool" {
  name = "megapool"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"
    # aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/arm64/recommended
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
    values = ["amzn2-ami-ecs-hvm-*-arm64-ebs"]
  }

  owners = ["amazon"]
}

resource "aws_launch_configuration" "megapool" {
  name_prefix = "${aws_ecs_cluster.megapool.name}-"

  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t4g.micro"

  security_groups      = var.ec2_security_groups
  iam_instance_profile = var.iam_instance_profile
  key_name             = var.ssh_key

  user_data = <<-EOH
  #cloud-config
  bootcmd:
    - cloud-init-per instance $(echo "ECS_CLUSTER=${aws_ecs_cluster.megapool.name}" >> /etc/ecs/ecs.config)
  EOH

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration#using-with-autoscaling-groups
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "megapool" {
  name                 = aws_ecs_cluster.megapool.name
  vpc_zone_identifier  = var.ec2_subnets
  launch_configuration = aws_launch_configuration.megapool.name

  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  health_check_grace_period = 300
  health_check_type         = "EC2"

  tag {
    key   = "Name"
    value = "megapool"

    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

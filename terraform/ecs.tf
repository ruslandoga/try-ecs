# stockholm
module "ecs_eu" {
  source = "./ecs"

  iam_instance_profile = aws_iam_instance_profile.ecs_instance.id
  vpc_id               = module.vpc_eu.vpc_id
  ec2_subnets          = module.vpc_eu.private_subnets
  lb_subnets           = module.vpc_eu.public_subnets
  docker_image         = var.docker_image
  ssh_key              = var.ssh_key

  ec2_security_groups = [
    module.vpc_eu.default_security_group_id,
    aws_security_group.allow_private_asia.id
  ]

  # TODO automate
  lb_certificate_arn = "arn:aws:acm:eu-north-1:154782911265:certificate/81c602c2-8673-44b6-a92d-c48193815d16"

  extra_lb_security_groups = [
    module.vpc_eu.default_security_group_id
  ]
}

# singapore
module "ecs_asia" {
  source = "./ecs"

  iam_instance_profile = aws_iam_instance_profile.ecs_instance.id
  vpc_id               = module.vpc_asia.vpc_id
  ec2_subnets          = module.vpc_asia.private_subnets
  lb_subnets           = module.vpc_asia.public_subnets
  docker_image         = var.docker_image

  ec2_security_groups = [
    module.vpc_asia.default_security_group_id,
    aws_security_group.allow_private_eu.id
  ]

  # TODO automate
  lb_certificate_arn = "arn:aws:acm:ap-southeast-1:154782911265:certificate/7c71dd86-5e68-47b6-8dc3-5ec657bd5847"

  extra_lb_security_groups = [
    module.vpc_asia.default_security_group_id
  ]

  providers = {
    aws = aws.asia
  }
}

output "eu_lb" {
  value = module.ecs_eu.lb_dns
}

output "asia_lb" {
  value = module.ecs_asia.lb_dns
}

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
    module.vpc_eu_asia_peering.security_group_from_id,
    module.vpc_eu_us_peering.security_group_from_id
  ]

  # TODO automate
  lb_certificate_arn = "arn:aws:acm:eu-north-1:154782911265:certificate/62f1ea26-107b-41d2-b21e-e72016191b6c"

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
    module.vpc_eu_asia_peering.security_group_to_id,
    module.vpc_us_asia_peering.security_group_to_id
  ]

  # TODO automate
  lb_certificate_arn = "arn:aws:acm:ap-southeast-1:154782911265:certificate/9b35355d-f0e0-4604-84d8-a19831aa98fb"

  extra_lb_security_groups = [
    module.vpc_asia.default_security_group_id
  ]

  providers = {
    aws = aws.asia
  }
}

# usa
module "ecs_us" {
  source = "./ecs"

  iam_instance_profile = aws_iam_instance_profile.ecs_instance.id
  vpc_id               = module.vpc_us.vpc_id
  ec2_subnets          = module.vpc_us.private_subnets
  lb_subnets           = module.vpc_us.public_subnets
  docker_image         = var.docker_image

  ec2_security_groups = [
    module.vpc_us.default_security_group_id,
    module.vpc_eu_us_peering.security_group_to_id,
    module.vpc_us_asia_peering.security_group_from_id
  ]

  # TODO automate
  lb_certificate_arn = "arn:aws:acm:us-west-1:154782911265:certificate/6675795a-00df-4c4f-aa7a-340769ab62f2"

  extra_lb_security_groups = [
    module.vpc_us.default_security_group_id
  ]

  providers = {
    aws = aws.us
  }
}

output "eu_lb" {
  value = module.ecs_eu.lb_dns
}

output "asia_lb" {
  value = module.ecs_asia.lb_dns
}

output "us_lb" {
  value = module.ecs_us.lb_dns
}

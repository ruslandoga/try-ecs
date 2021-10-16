module "bastion" {
  source = "./bastion"

  myip            = var.myip
  bastion_enabled = var.bastion_enabled
  ssh_key         = var.ssh_key

  vpc_id    = module.vpc_eu.vpc_id
  subnet_id = module.vpc_eu.public_subnets[0]

  extra_security_group_ids = [
    module.vpc_eu.default_security_group_id
  ]
}

output "bastion_public_ip" {
  value = var.bastion_enabled ? module.bastion.public_ip : "No-bastion"
}

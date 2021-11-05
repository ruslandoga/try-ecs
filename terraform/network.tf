module "vpc_eu" {
  source = "terraform-aws-modules/vpc/aws"

  name = "megapool"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}

module "vpc_asia" {
  source = "terraform-aws-modules/vpc/aws"

  name = "megapool"
  cidr = "10.1.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "test"
  }

  providers = {
    aws = aws.asia
  }
}

module "vpc_us" {
  source = "terraform-aws-modules/vpc/aws"

  name = "megapool"
  cidr = "10.2.0.0/16"

  azs             = ["us-west-1a", "us-west-1b"]
  private_subnets = ["10.2.1.0/24", "10.2.2.0/24"]
  public_subnets  = ["10.2.101.0/24", "10.2.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "test"
  }

  providers = {
    aws = aws.us
  }
}

module "vpc_eu_asia_peering" {
  source = "./peering"

  from = {
    vpc_id         = module.vpc_eu.vpc_id
    route_table_id = module.vpc_eu.private_route_table_ids[0]
    cidr_block     = module.vpc_eu.vpc_cidr_block # or "10.1.0.0/22"
    subnets        = module.vpc_eu.private_subnets_cidr_blocks
    region         = "eu-north-1"
  }

  to = {
    vpc_id         = module.vpc_asia.vpc_id
    route_table_id = module.vpc_asia.private_route_table_ids[0]
    cidr_block     = module.vpc_asia.vpc_cidr_block # or "10.0.0.0/22"
    subnets        = module.vpc_asia.private_subnets_cidr_blocks
    region         = "ap-southeast-1"
  }
}

module "vpc_eu_us_peering" {
  source = "./peering"

  from = {
    vpc_id         = module.vpc_eu.vpc_id
    route_table_id = module.vpc_eu.private_route_table_ids[0]
    cidr_block     = module.vpc_eu.vpc_cidr_block
    subnets        = module.vpc_eu.private_subnets_cidr_blocks
    region         = "eu-north-1"
  }

  to = {
    vpc_id         = module.vpc_us.vpc_id
    route_table_id = module.vpc_us.private_route_table_ids[0]
    cidr_block     = module.vpc_us.vpc_cidr_block
    subnets        = module.vpc_us.private_subnets_cidr_blocks
    region         = "us-west-1"
  }
}

module "vpc_us_asia_peering" {
  source = "./peering"

  from = {
    vpc_id         = module.vpc_us.vpc_id
    route_table_id = module.vpc_us.private_route_table_ids[0]
    cidr_block     = module.vpc_us.vpc_cidr_block
    subnets        = module.vpc_us.private_subnets_cidr_blocks
    region         = "us-west-1"
  }

  to = {
    vpc_id         = module.vpc_asia.vpc_id
    route_table_id = module.vpc_asia.private_route_table_ids[0]
    cidr_block     = module.vpc_asia.vpc_cidr_block
    subnets        = module.vpc_asia.private_subnets_cidr_blocks
    region         = "ap-southeast-1"
  }
}

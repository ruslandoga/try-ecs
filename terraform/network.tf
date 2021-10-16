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

resource "aws_vpc_peering_connection" "eu_asia_requester" {
  vpc_id = module.vpc_eu.vpc_id

  peer_vpc_id = module.vpc_asia.vpc_id
  peer_region = "ap-southeast-1"

  auto_accept = false

  # accepter {
  #   allow_remote_vpc_dns_resolution = true
  # }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Terraform = "true"
    Side      = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "asia_eu_accepter" {
  provider = aws.asia

  vpc_peering_connection_id = aws_vpc_peering_connection.eu_asia_requester.id

  auto_accept = true

  tags = {
    Terraform = "true"
    Side      = "Accepter"
  }

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  # requester {
  #   allow_remote_vpc_dns_resolution = true
  # }
}

# eu <-> asia private route table routes

resource "aws_route" "private_peering_eu_asia" {
  route_table_id            = module.vpc_eu.private_route_table_ids[0]
  destination_cidr_block    = module.vpc_asia.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.eu_asia_requester.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "private_peering_asia_eu" {
  provider = aws.asia

  route_table_id            = module.vpc_asia.private_route_table_ids[0]
  destination_cidr_block    = module.vpc_eu.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.eu_asia_requester.id

  timeouts {
    create = "5m"
  }
}

# eu <-> asia firewalls

resource "aws_security_group" "allow_private_asia" {
  name        = "allow_private_asia"
  description = "allow private subnets from asia"
  vpc_id      = module.vpc_eu.vpc_id

  ingress = [
    {
      description = "All traffic from private subnets in Asia"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = module.vpc_asia.private_subnets_cidr_blocks

      # why do I need to specify these
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = null
    }
  ]

  egress = [
    {
      description = "All traffic to private subnets in Asia"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = module.vpc_asia.private_subnets_cidr_blocks

      # why do I need to specify these
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = null
    }
  ]
}

resource "aws_security_group" "allow_private_eu" {
  provider = aws.asia

  name        = "allow_private_eu"
  description = "allow private subnets from eu"
  vpc_id      = module.vpc_asia.vpc_id

  ingress = [
    {
      description = "All traffic from private subnets in EU"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = module.vpc_eu.private_subnets_cidr_blocks

      # why do I need to specify these
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = null
    }
  ]

  egress = [
    {
      description = "All traffic to private subnets in EU"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = module.vpc_eu.private_subnets_cidr_blocks

      # why do I need to specify these
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = null
    }
  ]
}

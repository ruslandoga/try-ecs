terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  alias  = "from"
  region = var.from.region
}

provider "aws" {
  alias  = "to"
  region = var.to.region
}

# peering

resource "aws_vpc_peering_connection" "requester" {
  provider = aws.from

  vpc_id      = var.from.vpc_id
  peer_vpc_id = var.to.vpc_id
  peer_region = var.to.region

  auto_accept = false

  # requester {
  #   allow_remote_vpc_dns_resolution = true
  # }

  tags = {
    Terraform = "true"
    Side      = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider = aws.to

  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id

  auto_accept = true

  tags = {
    Terraform = "true"
    Side      = "Accepter"
  }

  # accepter {
  #   allow_remote_vpc_dns_resolution = true
  # }
}

# routing

resource "aws_route" "from" {
  provider = aws.from

  route_table_id            = var.from.route_table_id
  destination_cidr_block    = var.to.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "to" {
  provider = aws.to

  route_table_id            = var.to.route_table_id
  destination_cidr_block    = var.from.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id

  timeouts {
    create = "5m"
  }
}

# firewalls

resource "aws_security_group" "from" {
  provider = aws.from

  vpc_id = var.from.vpc_id

  ingress {
    description = "All traffic from subnets in peering region ${var.to.region}"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.to.subnets
  }

  egress {
    description = "All traffic to subnets in peering region ${var.to.region}"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.to.subnets
  }
}

resource "aws_security_group" "to" {
  provider = aws.to

  vpc_id = var.to.vpc_id

  ingress {
    description = "All traffic from subnets in peering region ${var.from.region}"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.from.subnets
  }

  egress {
    description = "All traffic to subnets in peering region ${var.from.region}"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.from.subnets
  }
}

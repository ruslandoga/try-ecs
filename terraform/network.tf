resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Name = "Default VPC"
  }
}

data "aws_subnet_ids" "vpc_subnets" {
  vpc_id = aws_vpc.main.id
}

data "aws_subnet" "default_subnet" {
  count = 3 // length(data.aws_subnet_ids.vpc_subnets.ids)
  id    = tolist(data.aws_subnet_ids.vpc_subnets.ids)[count.index]
}

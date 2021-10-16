# ec2 instance with public ip address and port 22 open to tunnel ssh connections to ecs cluster
# based on https://minhajuddin.com/2020/05/06/how-to-create-temporary-bastion-ec2-instances-using-terraform/

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "bastion" {
  name   = "bastion"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.myip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami   = data.aws_ami.ubuntu.id
  count = var.bastion_enabled ? 1 : 0

  instance_type = "t4g.micro"
  key_name      = var.ssh_key
  subnet_id     = var.subnet_id

  associate_public_ip_address = true

  vpc_security_group_ids = concat([aws_security_group.bastion.id], var.extra_security_group_ids)

  tags = {
    Name = "Bastion"
  }
}

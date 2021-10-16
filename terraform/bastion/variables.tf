variable "ssh_key" {
  description = "Specifies the SSH key name to use"
  type        = string
}

variable "bastion_enabled" {
  description = "Spins up a bastion host if enabled"
  type        = bool
}

variable "myip" {
  description = "My IP to allow SSH access into the bastion server"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC to place the bastion instance in"
  type        = string
}

variable "subnet_id" {
  description = "Subnet to place the bastion instance in"
  type        = string
}

variable "extra_security_group_ids" {
  description = "Extra security grups to add to the bastion instance"
  type        = list(string)
}

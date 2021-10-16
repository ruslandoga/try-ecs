variable "docker_image" {
  description = "Specifies the docker image tag to use"
  type        = string
}

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

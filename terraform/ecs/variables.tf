variable "docker_image" {
  description = "Docker image to deploy on ECS"
  type        = string
}

variable "ssh_key" {
  description = "Specifies the SSH key name to use"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM instance profile to use for ECS instances"
  type        = string
}

variable "container_http_port" {
  type    = number
  default = 4000
}

variable "vpc_id" {
  type = string
}

variable "extra_lb_security_groups" {
  type = list(string)
}

variable "lb_subnets" {
  type = list(string)
}

variable "lb_certificate_arn" {
  type = string
}

variable "ec2_subnets" {
  type = list(string)
}

variable "ec2_security_groups" {
  type    = list(string)
  default = []
}

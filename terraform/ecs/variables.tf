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

variable "database_url" {
  type = string
}

variable "discovery_regions" {
  type = list(string)
}

variable "primary_host_prefix" {
  type = string
}

variable "erl_release_cookie" {
  type = string

  # TODO doesn't need to be this complex, can be name of the cluster, network is already private
  default = "kka+STG7DXGVweA24KXsKkb+oBVMg7RHd9t5i3KrkUD0e1GBYr2VLO1xG7p+IxFY"
}

variable "phx_secret_key_base" {
  type = string
  # TODO needs to be secret
  default = "7xXiSaNsw/5DHJrzT7YMArinaSAJG521GOncKdmOECUIljE6WHHGKCqyqOXmREqw"
}

variable "web_host" {
  type = string
}

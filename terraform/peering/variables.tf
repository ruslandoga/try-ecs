variable "from" {
  type = object({
    vpc_id         = string
    route_table_id = string
    cidr_block     = string
    subnets        = list(string)
    region         = string
  })
}

variable "to" {
  type = object({
    vpc_id         = string
    route_table_id = string
    cidr_block     = string
    subnets        = list(string)
    region         = string
  })
}

# module "db_asia" {
#   source  = "terraform-aws-modules/rds/aws"
#   version = "~> 3.0"

#   engine         = "postgres"
#   engine_version = "13.3"

#   instance_class    = "db.t4g.micro"
#   allocated_storage = 20

#   name     = "megapool-db"
#   username = "megapool"
#   password = "megapass"
#   port     = "5432"


# }

# module "db_us" {
#   source  = "terraform-aws-modules/rds/aws"
#   version = "~> 3.0"


# }

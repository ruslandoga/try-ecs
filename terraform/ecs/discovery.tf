# resource "aws_service_discovery_private_dns_namespace" "megapool" {
#   name        = "svc.megapool.cluster"
#   description = "Namespace for megapool nodes discovery"
#   vpc         = module.vpc.vpc_id
# }

# resource "aws_service_discovery_service" "megapool" {
#   name = "elixir"

#   dns_config {
#     namespace_id = aws_service_discovery_private_dns_namespace.megapool.id

#     dns_records {
#       ttl  = 10
#       type = "SRV"
#     }

#     routing_policy = "MULTIVALUE"
#   }
# }

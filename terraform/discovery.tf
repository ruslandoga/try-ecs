resource "aws_service_discovery_private_dns_namespace" "dns_namespace" {
  name        = "ecs-test.local"
  description = "some desc"
  vpc         = aws_vpc.main.id
}

resource "aws_service_discovery_service" "service_discovery" {
  name = "ecs-test"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.dns_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}

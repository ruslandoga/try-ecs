output "public_ip" {
  value = var.bastion_enabled ? aws_instance.bastion[0].public_ip : "No-bastion"
}

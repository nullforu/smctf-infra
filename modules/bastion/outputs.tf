output "instance_id" {
  value = var.create ? aws_instance.bastion[0].id : null
}

output "private_ip" {
  value = var.create ? aws_instance.bastion[0].private_ip : null
}

output "security_group_id" {
  value = var.create ? aws_security_group.bastion[0].id : null
}

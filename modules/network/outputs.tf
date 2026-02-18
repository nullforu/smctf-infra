output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = values(aws_subnet.public)[*].id
}

output "private_subnet_ids" {
  value = values(aws_subnet.private)[*].id
}

output "protected_subnet_ids" {
  value = values(aws_subnet.protected)[*].id
}

output "azs" {
  value = var.azs
}

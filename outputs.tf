output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "protected_subnet_ids" {
  value = module.network.protected_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "alb_security_group_id" {
  value = module.eks.alb_security_group_id
}

output "irsa_alb_role_arn" {
  value = module.irsa.irsa_alb_role_arn
}

output "irsa_container_provisioner_role_arn" {
  value = module.irsa.irsa_container_provisioner_role_arn
}

output "irsa_backend_role_arn" {
  value = module.irsa.irsa_backend_role_arn
}

output "irsa_fluentbit_role_arn" {
  value = module.irsa.irsa_fluentbit_role_arn
}

output "irsa_alb_policy_arn" {
  value = module.irsa.irsa_alb_policy_arn
}

output "irsa_dynamodb_policy_arn" {
  value = module.irsa.irsa_dynamodb_policy_arn
}

output "irsa_s3_policy_arn" {
  value = module.irsa.irsa_s3_policy_arn
}

output "irsa_ecr_policy_arn" {
  value = module.irsa.irsa_ecr_policy_arn
}

output "irsa_cloudwatch_logs_policy_arn" {
  value = module.irsa.irsa_cloudwatch_logs_policy_arn
}

output "rds_endpoint" {
  value = module.db.rds_endpoint
}

output "redis_primary_endpoint" {
  value = module.db.redis_primary_endpoint
}

output "s3_challenge_bucket" {
  value = module.storage.s3_bucket_name
}

output "ecr_repository_urls" {
  value = module.storage.ecr_repository_urls
}

output "ecr_repository_arns" {
  value = module.storage.ecr_repository_arns
}

output "dynamodb_table_name" {
  value = module.storage.dynamodb_table_name
}

output "bastion_instance_id" {
  value       = module.bastion.instance_id
  description = "Bastion instance ID (if created)."
}

output "bastion_private_ip" {
  value       = module.bastion.private_ip
  description = "Bastion private IP (if created)."
}

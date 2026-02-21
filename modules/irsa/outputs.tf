output "irsa_alb_role_arn" {
  value = aws_iam_role.irsa_alb.arn
}

output "irsa_container_provisioner_role_arn" {
  value = aws_iam_role.irsa_container_provisioner.arn
}

output "irsa_backend_role_arn" {
  value = aws_iam_role.irsa_backend.arn
}

output "irsa_fluentbit_role_arn" {
  value = aws_iam_role.irsa_fluentbit.arn
}

output "irsa_alb_policy_arn" {
  value = aws_iam_policy.alb_controller.arn
}

output "irsa_dynamodb_policy_arn" {
  value = aws_iam_policy.dynamodb_access.arn
}

output "irsa_s3_policy_arn" {
  value = aws_iam_policy.s3_access.arn
}

output "irsa_ecr_policy_arn" {
  value = aws_iam_policy.ecr_access.arn
}

output "irsa_cloudwatch_logs_policy_arn" {
  value = aws_iam_policy.cloudwatch_logs.arn
}

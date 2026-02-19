output "s3_bucket_name" {
  value = var.create_s3_challenge_bucket ? aws_s3_bucket.challenge_files[0].bucket : data.aws_s3_bucket.challenge_files[0].bucket
}

output "s3_bucket_arn" {
  value = var.create_s3_challenge_bucket ? aws_s3_bucket.challenge_files[0].arn : data.aws_s3_bucket.challenge_files[0].arn
}

output "ecr_repository_urls" {
  value = var.create_ecr_repositories ? { for name, repo in aws_ecr_repository.repos : name => repo.repository_url } : { for name, repo in data.aws_ecr_repository.repos : name => repo.repository_url }
}

output "ecr_repository_arns" {
  value = var.create_ecr_repositories ? { for name, repo in aws_ecr_repository.repos : name => repo.arn } : { for name, repo in data.aws_ecr_repository.repos : name => repo.arn }
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.stacks.name
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.stacks.arn
}

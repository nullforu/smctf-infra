output "s3_bucket_name" {
  value = aws_s3_bucket.challenge_files.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.challenge_files.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.challenges.repository_url
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.stacks.name
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.stacks.arn
}

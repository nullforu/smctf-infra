variable "name_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "s3_challenge_bucket_name" {
  type = string
}

variable "create_s3_challenge_bucket" {
  type        = bool
  description = "Whether to create the challenge files bucket."
  default     = true

  validation {
    condition     = var.create_s3_challenge_bucket || (var.s3_challenge_bucket_name != null && trim(var.s3_challenge_bucket_name) != "")
    error_message = "When create_s3_challenge_bucket is false, s3_challenge_bucket_name must be set."
  }
}

variable "s3_cors_rules" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
}

variable "ecr_repository_names" {
  type = list(string)
}

variable "create_ecr_repositories" {
  type        = bool
  description = "Whether to create ECR repositories."
  default     = true
}

variable "dynamodb_table_name" {
  type = string
}

variable "dynamodb_billing_mode" {
  type = string
}

variable "dynamodb_read_capacity" {
  type = number
}

variable "dynamodb_write_capacity" {
  type = number
}

variable "enable_point_in_time_recovery" {
  type = bool
}

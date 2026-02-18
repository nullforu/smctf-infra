variable "name_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "s3_challenge_bucket_name" {
  type = string
}

variable "ecr_repository_name" {
  type = string
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

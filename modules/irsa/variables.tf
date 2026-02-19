variable "name_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_issuer_url" {
  type = string
}

variable "irsa_namespace" {
  type = string
}

variable "irsa_alb_namespace" {
  type = string
}

variable "irsa_service_accounts" {
  type = map(string)
}

variable "dynamodb_table_arn" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}

variable "alb_policy_json" {
  type = any
}

variable "ecr_repository_arns" {
  type = list(string)
}

resource "aws_s3_bucket" "challenge_files" {
  count  = var.create_s3_challenge_bucket ? 1 : 0
  bucket = coalesce(var.s3_challenge_bucket_name, "${var.name_prefix}-challenges")

  tags = var.tags
}

data "aws_s3_bucket" "challenge_files" {
  count  = var.create_s3_challenge_bucket ? 0 : 1
  bucket = var.s3_challenge_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "challenge_files" {
  count  = var.create_s3_challenge_bucket ? 1 : 0
  bucket = aws_s3_bucket.challenge_files[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "challenge_files" {
  count  = var.create_s3_challenge_bucket ? 1 : 0
  bucket = aws_s3_bucket.challenge_files[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "challenge_files" {
  count  = var.create_s3_challenge_bucket ? 1 : 0
  bucket = aws_s3_bucket.challenge_files[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "challenge_files" {
  count  = var.create_s3_challenge_bucket && length(var.s3_cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.challenge_files[0].id

  dynamic "cors_rule" {
    for_each = var.s3_cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_ecr_repository" "repos" {
  for_each             = var.create_ecr_repositories ? toset(var.ecr_repository_names) : toset([])
  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

data "aws_ecr_repository" "repos" {
  for_each = var.create_ecr_repositories ? toset([]) : toset(var.ecr_repository_names)
  name     = each.value
}

resource "aws_dynamodb_table" "stacks" {
  name         = var.dynamodb_table_name
  billing_mode = var.dynamodb_billing_mode

  read_capacity  = var.dynamodb_billing_mode == "PROVISIONED" ? var.dynamodb_read_capacity : null
  write_capacity = var.dynamodb_billing_mode == "PROVISIONED" ? var.dynamodb_write_capacity : null

  hash_key  = "pk"
  range_key = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  attribute {
    name = "gsi1pk"
    type = "S"
  }

  attribute {
    name = "gsi1sk"
    type = "S"
  }

  global_secondary_index {
    name            = "gsi1"
    projection_type = "ALL"

    key_schema {
      attribute_name = "gsi1pk"
      key_type       = "HASH"
    }

    key_schema {
      attribute_name = "gsi1sk"
      key_type       = "RANGE"
    }

    read_capacity  = var.dynamodb_billing_mode == "PROVISIONED" ? var.dynamodb_read_capacity : null
    write_capacity = var.dynamodb_billing_mode == "PROVISIONED" ? var.dynamodb_write_capacity : null
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.tags, {
    Service = "container-provisioner"
  })
}

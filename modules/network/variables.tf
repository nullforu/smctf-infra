variable "name_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "protected_subnet_cidrs" {
  type = list(string)
}

variable "nat_gateway_mode" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "enable_ssm_vpc_endpoints" {
  type = bool
}

variable "enable_s3_vpc_endpoint" {
  type = bool
}

variable "enable_dynamodb_vpc_endpoint" {
  type = bool
}

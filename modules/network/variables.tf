variable "name_prefix" {
  type        = string
  description = "Name prefix for resources."
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR."
}

variable "azs" {
  type        = list(string)
  description = "AZs to use."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs."
}

variable "protected_subnet_cidrs" {
  type        = list(string)
  description = "Protected subnet CIDRs."
}

variable "nat_gateway_mode" {
  type        = string
  description = "NAT gateway placement: single or per_az."
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name (for subnet tags)."
}

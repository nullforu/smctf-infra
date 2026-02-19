variable "name_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "eks_cluster_name" {
  type = string
}

variable "eks_version" {
  type = string
}

variable "eks_endpoint_public_access" {
  type = bool
}

variable "eks_endpoint_private_access" {
  type = bool
}

variable "stack_node_instance_types" {
  type = list(string)
}

variable "stack_node_desired_size" {
  type = number
}

variable "stack_node_min_size" {
  type = number
}

variable "stack_node_max_size" {
  type = number
}

variable "backend_node_instance_types" {
  type = list(string)
}

variable "backend_node_desired_size" {
  type = number
}

variable "backend_node_min_size" {
  type = number
}

variable "backend_node_max_size" {
  type = number
}

variable "stack_nodeport_range" {
  type = object({ from = number, to = number })
}

variable "backend_nodeport_range" {
  type = object({ from = number, to = number })
}

variable "stack_nodeport_cidrs" {
  type = list(string)
}

variable "alb_ingress_cidrs" {
  type = list(string)
}

variable "extra_node_role_policy_arns" {
  type = list(string)
}

variable "enable_network_policy" {
  type = bool
}

variable "vpc_cni_addon_version" {
  type = string
}

variable "vpc_cni_service_account_role_arn" {
  type = string
}

variable "coredns_addon_version" {
  type = string
}

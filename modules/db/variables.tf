variable "name_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "protected_subnet_ids" {
  type = list(string)
}

variable "backend_nodes_sg_id" {
  type = string
}

variable "rds_instance_class" {
  type = string
}

variable "rds_allocated_storage_gb" {
  type = number
}

variable "rds_multi_az" {
  type = bool
}

variable "rds_engine_version" {
  type = string
}

variable "rds_db_name" {
  type = string
}

variable "rds_master_username" {
  type = string
}

variable "rds_master_password" {
  type = string
}

variable "rds_backup_retention_days" {
  type = number
}

variable "rds_deletion_protection" {
  type = bool
}

variable "redis_node_type" {
  type = string
}

variable "redis_engine_version" {
  type = string
}

variable "redis_multi_az" {
  type = bool
}

variable "redis_num_cache_nodes" {
  type = number
}


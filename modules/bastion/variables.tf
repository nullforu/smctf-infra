variable "name_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "create" {
  type = bool
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "subnet_index" {
  type = number
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "root_volume_size" {
  type = number
}

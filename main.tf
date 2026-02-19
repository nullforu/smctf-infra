provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-be6f"
    key            = "smctf/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-be6f"
    encrypt        = true
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"

  tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.common_tags
  )

  alb_policy_json = yamldecode(file("${path.module}/polices/elb_irsa_policy.yaml"))
}

module "network" {
  source = "./modules/network"

  name_prefix = local.name_prefix
  tags        = local.tags

  vpc_cidr               = var.vpc_cidr
  azs                    = var.azs
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  protected_subnet_cidrs = var.protected_subnet_cidrs
  nat_gateway_mode       = var.nat_gateway_mode
  eks_cluster_name       = var.eks_cluster_name

  enable_ssm_vpc_endpoints     = var.enable_ssm_vpc_endpoints
  enable_s3_vpc_endpoint       = var.enable_s3_vpc_endpoint
  enable_dynamodb_vpc_endpoint = var.enable_dynamodb_vpc_endpoint
}

module "eks" {
  source = "./modules/eks"

  name_prefix = local.name_prefix
  tags        = local.tags

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  eks_cluster_name            = var.eks_cluster_name
  eks_version                 = var.eks_version
  eks_endpoint_public_access  = var.eks_endpoint_public_access
  eks_endpoint_private_access = var.eks_endpoint_private_access

  stack_node_instance_types = var.stack_node_instance_types
  stack_node_desired_size   = var.stack_node_desired_size
  stack_node_min_size       = var.stack_node_min_size
  stack_node_max_size       = var.stack_node_max_size

  backend_node_instance_types = var.backend_node_instance_types
  backend_node_desired_size   = var.backend_node_desired_size
  backend_node_min_size       = var.backend_node_min_size
  backend_node_max_size       = var.backend_node_max_size

  stack_nodeport_range   = var.stack_nodeport_range
  backend_nodeport_range = var.backend_nodeport_range
  stack_nodeport_cidrs   = var.stack_nodeport_cidrs
  alb_ingress_cidrs      = var.alb_ingress_cidrs

  extra_node_role_policy_arns      = var.extra_node_role_policy_arns
  enable_network_policy            = var.enable_network_policy
  vpc_cni_addon_version            = var.vpc_cni_addon_version
  vpc_cni_service_account_role_arn = var.vpc_cni_service_account_role_arn
  coredns_addon_version            = var.coredns_addon_version
}

module "storage" {
  source = "./modules/storage"

  name_prefix = local.name_prefix
  tags        = local.tags

  s3_challenge_bucket_name   = var.s3_challenge_bucket_name
  create_s3_challenge_bucket = var.create_s3_challenge_bucket
  s3_cors_rules              = var.s3_cors_rules

  ecr_repository_names    = var.ecr_repository_names
  create_ecr_repositories = var.create_ecr_repositories

  dynamodb_table_name           = var.dynamodb_table_name
  dynamodb_billing_mode         = var.dynamodb_billing_mode
  dynamodb_read_capacity        = var.dynamodb_read_capacity
  dynamodb_write_capacity       = var.dynamodb_write_capacity
  enable_point_in_time_recovery = var.enable_point_in_time_recovery
}

module "irsa" {
  source = "./modules/irsa"

  name_prefix = local.name_prefix
  tags        = local.tags

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url   = module.eks.oidc_issuer_url

  irsa_namespace        = var.irsa_namespace
  irsa_alb_namespace    = var.irsa_alb_namespace
  irsa_service_accounts = var.irsa_service_accounts

  dynamodb_table_arn  = module.storage.dynamodb_table_arn
  s3_bucket_arn       = module.storage.s3_bucket_arn
  ecr_repository_arns = values(module.storage.ecr_repository_arns)

  alb_policy_json = local.alb_policy_json
}

module "db" {
  source = "./modules/db"

  name_prefix = local.name_prefix
  tags        = local.tags

  protected_subnet_ids = module.network.protected_subnet_ids
  backend_nodes_sg_id  = module.eks.backend_nodes_sg_id
  bastion_sg_id        = module.bastion.security_group_id

  rds_instance_class        = var.rds_instance_class
  rds_allocated_storage_gb  = var.rds_allocated_storage_gb
  rds_multi_az              = var.rds_multi_az
  rds_engine_version        = var.rds_engine_version
  rds_db_name               = var.rds_db_name
  rds_master_username       = var.rds_master_username
  rds_master_password       = var.rds_master_password
  rds_backup_retention_days = var.rds_backup_retention_days
  rds_deletion_protection   = var.rds_deletion_protection

  redis_node_type       = var.redis_node_type
  redis_engine_version  = var.redis_engine_version
  redis_multi_az        = var.redis_multi_az
  redis_num_cache_nodes = var.redis_num_cache_nodes
}

module "bastion" {
  source = "./modules/bastion"

  name_prefix = local.name_prefix
  tags        = local.tags

  create             = var.create_bastion
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  subnet_index       = var.bastion_subnet_index
  ami_id             = var.bastion_ami_id
  instance_type      = var.bastion_instance_type
  key_name           = var.bastion_key_name
  root_volume_size   = var.bastion_root_volume_size
}

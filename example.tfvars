project     = "smctf"
environment = "dev"
region      = "ap-northeast-2"
azs         = ["ap-northeast-2a", "ap-northeast-2c"]

common_tags = {}

vpc_cidr               = "10.0.0.0/16"
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs   = ["10.0.11.0/24", "10.0.21.0/24"]
protected_subnet_cidrs = ["10.0.111.0/24", "10.0.121.0/24"]

nat_gateway_mode = "single"

eks_cluster_name            = "smctf"
eks_version                 = "1.35"
eks_endpoint_public_access  = false
eks_endpoint_private_access = true

stack_node_instance_types = ["t3a.medium"]
stack_node_desired_size   = 2
stack_node_min_size       = 1
stack_node_max_size       = 4

backend_node_instance_types = ["t3a.medium"]
backend_node_desired_size   = 2
backend_node_min_size       = 1
backend_node_max_size       = 4

stack_nodeport_cidrs = ["0.0.0.0/0"]
stack_nodeport_range = {
  from = 31001
  to   = 32767
}

backend_nodeport_range = {
  from = 30000
  to   = 31000
}

alb_ingress_cidrs = ["0.0.0.0/0"]

rds_instance_class        = "db.t3.micro"
rds_allocated_storage_gb  = 20
rds_multi_az              = false
rds_engine_version        = null
rds_db_name               = "smctf"
rds_master_username       = "smctf_admin"
rds_master_password       = "REPLACE_ME"
rds_backup_retention_days = 7
rds_deletion_protection   = true

redis_node_type       = "cache.t3.micro"
redis_engine_version  = null
redis_multi_az        = false
redis_num_cache_nodes = 1

s3_challenge_bucket_name   = "smctf-challenges-bucket"
create_s3_challenge_bucket = false
# s3_cors_rules = [
#   {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
#     allowed_origins = ["https://ctf.swua.kr"]
#     expose_headers  = ["ETag"]
#     max_age_seconds = 3000
#   }
# ]

ecr_repository_names    = ["backend", "container-provisioner", "smctf-challenges"]
create_ecr_repositories = false

dynamodb_table_name           = "smctf-container-provisioner-stacks"
dynamodb_billing_mode         = "PAY_PER_REQUEST"
dynamodb_read_capacity        = 5
dynamodb_write_capacity       = 5
enable_point_in_time_recovery = true

irsa_namespace         = "backend"
irsa_alb_namespace     = "kube-system"
irsa_logging_namespace = "logging"
irsa_service_accounts = {
  alb_controller        = "aws-load-balancer-controller"
  container_provisioner = "container-provisioner"
  backend_service       = "smctf-backend"
  fluentbit             = "fluent-bit-cloudwatch"
}

extra_node_role_policy_arns = []

enable_network_policy            = true
vpc_cni_addon_version            = null
vpc_cni_service_account_role_arn = null
coredns_addon_version            = null

create_bastion           = false
bastion_instance_type    = "t3.micro"
bastion_ami_id           = null
bastion_subnet_index     = 0
bastion_root_volume_size = 20
bastion_key_name         = null

enable_ssm_vpc_endpoints     = true
enable_s3_vpc_endpoint       = true
enable_dynamodb_vpc_endpoint = true

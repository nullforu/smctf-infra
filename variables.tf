variable "project" {
  type        = string
  description = "Project name."
  default     = "smctf"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)."
  default     = "dev"
}

variable "region" {
  type        = string
  description = "AWS region."
  default     = "ap-northeast-2"
}

variable "azs" {
  type        = list(string)
  description = "AZs to use (must be 2 for this design)."
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "common_tags" {
  type        = map(string)
  description = "Extra tags applied to all resources."
  default     = {}
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs for stack nodes."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs for backend nodes."
  default     = ["10.0.11.0/24", "10.0.21.0/24"]
}

variable "protected_subnet_cidrs" {
  type        = list(string)
  description = "Protected subnet CIDRs for DBs."
  default     = ["10.0.111.0/24", "10.0.121.0/24"]
}

variable "nat_gateway_mode" {
  type        = string
  description = "NAT gateway placement: single or per_az."
  default     = "single"
  validation {
    condition     = contains(["single", "per_az"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be single or per_az."
  }
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name."
  default     = "smctf"
}

variable "eks_version" {
  type        = string
  description = "Kubernetes version for EKS."
  default     = "1.34"
}

variable "eks_endpoint_public_access" {
  type        = bool
  description = "Whether EKS endpoint is public."
  default     = false
}

variable "eks_endpoint_private_access" {
  type        = bool
  description = "Whether EKS endpoint is private."
  default     = true
}

variable "stack_node_instance_types" {
  type        = list(string)
  description = "Instance types for stack node group."
  default     = ["t3a.medium"]
}

variable "stack_node_desired_size" {
  type        = number
  description = "Desired size for stack node group."
  default     = 2
}

variable "stack_node_min_size" {
  type        = number
  description = "Min size for stack node group."
  default     = 1
}

variable "stack_node_max_size" {
  type        = number
  description = "Max size for stack node group."
  default     = 4
}

variable "backend_node_instance_types" {
  type        = list(string)
  description = "Instance types for backend node group."
  default     = ["t3a.medium"]
}

variable "backend_node_desired_size" {
  type        = number
  description = "Desired size for backend node group."
  default     = 2
}

variable "backend_node_min_size" {
  type        = number
  description = "Min size for backend node group."
  default     = 1
}

variable "backend_node_max_size" {
  type        = number
  description = "Max size for backend node group."
  default     = 4
}

variable "stack_nodeport_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to access stack NodePort range."
  default     = ["0.0.0.0/0"]
}


variable "stack_nodeport_range" {
  type = object({
    from = number
    to   = number
  })
  description = "NodePort range for stack nodes."
  default = {
    from = 31001
    to   = 32767
  }
}

variable "backend_nodeport_range" {
  type = object({
    from = number
    to   = number
  })
  description = "NodePort range for backend nodes (ALB target range)."
  default = {
    from = 30000
    to   = 31000
  }
}

variable "alb_ingress_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to access ALB (ingress)."
  default     = ["0.0.0.0/0"]
}

variable "rds_instance_class" {
  type        = string
  description = "RDS instance class."
  default     = "db.t3.micro"
}

variable "rds_allocated_storage_gb" {
  type        = number
  description = "RDS allocated storage in GB."
  default     = 20
}

variable "rds_multi_az" {
  type        = bool
  description = "Enable RDS Multi-AZ."
  default     = false
}

variable "rds_engine_version" {
  type        = string
  description = "RDS PostgreSQL engine version (null to use AWS default)."
  default     = null
}

variable "rds_db_name" {
  type        = string
  description = "RDS database name."
  default     = "smctf"
}

variable "rds_master_username" {
  type        = string
  description = "RDS master username."
  default     = "smctf_admin"
}

variable "rds_master_password" {
  type        = string
  description = "RDS master password."
  sensitive   = true
}

variable "rds_backup_retention_days" {
  type        = number
  description = "RDS backup retention days."
  default     = 7
}

variable "rds_deletion_protection" {
  type        = bool
  description = "Enable RDS deletion protection."
  default     = true
}

variable "redis_node_type" {
  type        = string
  description = "ElastiCache Redis node type."
  default     = "cache.t3.micro"
}

variable "redis_engine_version" {
  type        = string
  description = "ElastiCache Redis engine version (null to use AWS default)."
  default     = null
}

variable "redis_multi_az" {
  type        = bool
  description = "Enable Redis Multi-AZ / automatic failover."
  default     = false
}

variable "redis_num_cache_nodes" {
  type        = number
  description = "Number of cache nodes (1 for single-AZ, 2+ for multi-AZ)."
  default     = 1
}

variable "s3_challenge_bucket_name" {
  type        = string
  description = "S3 bucket name for challenge files."
  default     = "smctf-challenges-bucket"
}

variable "create_s3_challenge_bucket" {
  type        = bool
  description = "Whether to create the challenge files bucket."
  default     = true

  validation {
    condition     = var.create_s3_challenge_bucket || (var.s3_challenge_bucket_name != null && trimspace(var.s3_challenge_bucket_name) != "")
    error_message = "When create_s3_challenge_bucket is false, s3_challenge_bucket_name must be set."
  }
}

variable "s3_cors_rules" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  description = "CORS rules for the challenge files bucket. Empty list disables CORS."
  default     = []
}

variable "ecr_repository_names" {
  type        = list(string)
  description = "ECR repository names to create (backend, provisioner, challenges, etc.)."
  default     = ["backend", "container-provisioner", "smctf-challenges"]
}

variable "create_ecr_repositories" {
  type        = bool
  description = "Whether to create ECR repositories."
  default     = true
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name for container-provisioner."
  default     = "smctf-container-provisioner-stacks"
}

variable "dynamodb_billing_mode" {
  type        = string
  description = "DynamoDB billing mode."
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_read_capacity" {
  type        = number
  description = "DynamoDB read capacity (for PROVISIONED)."
  default     = 5
}

variable "dynamodb_write_capacity" {
  type        = number
  description = "DynamoDB write capacity (for PROVISIONED)."
  default     = 5
}

variable "enable_point_in_time_recovery" {
  type        = bool
  description = "Enable DynamoDB point-in-time recovery."
  default     = true
}

variable "irsa_namespace" {
  type        = string
  description = "Kubernetes namespace for IRSA roles."
  default     = "backend"
}

variable "irsa_alb_namespace" {
  type        = string
  description = "Kubernetes namespace for ALB controller IRSA."
  default     = "kube-system"
}

variable "irsa_logging_namespace" {
  type        = string
  description = "Kubernetes namespace for logging IRSA."
  default     = "logging"
}

variable "irsa_service_accounts" {
  type        = map(string)
  description = "Service account names for IRSA roles."
  default = {
    alb_controller        = "aws-load-balancer-controller"
    container_provisioner = "container-provisioner"
    backend_service       = "smctf-backend"
    fluentbit             = "fluent-bit-cloudwatch"
  }
}

variable "extra_node_role_policy_arns" {
  type        = list(string)
  description = "Extra IAM policy ARNs to attach to EKS node role."
  default     = []
}

variable "enable_network_policy" {
  type        = bool
  description = "Enable EKS VPC CNI NetworkPolicy support."
  default     = true
}

variable "vpc_cni_addon_version" {
  type        = string
  description = "EKS VPC CNI addon version (null to use AWS default)."
  default     = null
}

variable "vpc_cni_service_account_role_arn" {
  type        = string
  description = "IRSA role ARN for the VPC CNI addon (optional)."
  default     = null
}

variable "coredns_addon_version" {
  type        = string
  description = "CoreDNS addon version (null to use AWS default)."
  default     = null
}


variable "create_bastion" {
  type        = bool
  description = "Whether to create a private-subnet bastion host (SSM only)."
  default     = false
}

variable "bastion_instance_type" {
  type        = string
  description = "EC2 instance type for bastion."
  default     = "t3.micro"
}

variable "bastion_ami_id" {
  type        = string
  description = "Optional AMI ID for bastion. If null, use latest Amazon Linux 2023."
  default     = null
}

variable "bastion_subnet_index" {
  type        = number
  description = "Index of private subnet to place bastion in."
  default     = 0
}

variable "bastion_root_volume_size" {
  type        = number
  description = "Root volume size (GB) for bastion."
  default     = 20
}

variable "bastion_key_name" {
  type        = string
  description = "Optional EC2 key pair name for bastion (SSM access doesn't require this)."
  default     = null
}

variable "enable_ssm_vpc_endpoints" {
  type        = bool
  description = "Create VPC interface endpoints for SSM/SSMMessages/EC2Messages."
  default     = true
}

variable "enable_s3_vpc_endpoint" {
  type        = bool
  description = "Create VPC gateway endpoint for S3."
  default     = true
}

variable "enable_dynamodb_vpc_endpoint" {
  type        = bool
  description = "Create VPC gateway endpoint for DynamoDB."
  default     = true
}

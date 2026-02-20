resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds"
  description = "RDS security group"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = compact([var.backend_nodes_sg_id, var.bastion_sg_id])
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds"
  })
}

resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis"
  description = "ElastiCache Redis security group"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = compact([var.backend_nodes_sg_id, var.bastion_sg_id])
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-redis"
  })
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-${substr(data.aws_vpc.selected.id, 0, 8)}"
  subnet_ids = var.protected_subnet_ids

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "main" {
  identifier                = "${var.name_prefix}-postgres"
  engine                    = "postgres"
  engine_version            = var.rds_engine_version
  instance_class            = var.rds_instance_class
  allocated_storage         = var.rds_allocated_storage_gb
  storage_encrypted         = true
  db_name                   = var.rds_db_name
  username                  = var.rds_master_username
  password                  = var.rds_master_password
  multi_az                  = var.rds_multi_az
  db_subnet_group_name      = aws_db_subnet_group.main.name
  vpc_security_group_ids    = [aws_security_group.rds.id]
  publicly_accessible       = false
  backup_retention_period   = var.rds_backup_retention_days
  deletion_protection       = var.rds_deletion_protection
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.name_prefix}-postgres-final-${formatdate("YYYYMMDDhhmm", time_static.rds_snapshot.rfc3339)}"

  tags = var.tags
}

resource "time_static" "rds_snapshot" {}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name_prefix}-redis-subnet-${substr(data.aws_vpc.selected.id, 0, 8)}"
  subnet_ids = var.protected_subnet_ids

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.name_prefix}-redis"
  description                = "Redis for smctf backend"
  node_type                  = var.redis_node_type
  engine                     = "redis"
  engine_version             = var.redis_engine_version
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.redis.id]
  automatic_failover_enabled = var.redis_multi_az
  multi_az_enabled           = var.redis_multi_az
  num_cache_clusters         = var.redis_num_cache_nodes
  port                       = 6379

  tags = var.tags
}

check "redis_multi_az_requires_2_nodes" {
  assert {
    condition     = (!var.redis_multi_az) || (var.redis_num_cache_nodes >= 2)
    error_message = "redis_multi_az=true requires redis_num_cache_nodes >= 2."
  }
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.any.vpc_id
}

data "aws_subnet" "any" {
  id = var.protected_subnet_ids[0]
}

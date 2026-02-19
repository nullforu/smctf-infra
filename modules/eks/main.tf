resource "aws_security_group" "eks_cluster" {
  name        = "${var.name_prefix}-eks-cluster"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eks-cluster"
  })
}

resource "aws_security_group" "stack_nodes" {
  name        = "${var.name_prefix}-stack-nodes"
  description = "Stack node group security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.stack_nodeport_range.from
    to_port     = var.stack_nodeport_range.to
    protocol    = "tcp"
    cidr_blocks = var.stack_nodeport_cidrs
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-stack-nodes"
  })
}

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb"
  description = "ALB security group for EKS ingress"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidrs
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb"
  })
}

resource "aws_security_group" "backend_nodes" {
  name        = "${var.name_prefix}-backend-nodes"
  description = "Backend node group security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.backend_nodeport_range.from
    to_port         = var.backend_nodeport_range.to
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-backend-nodes"
  })
}

resource "aws_security_group_rule" "eks_cluster_from_stack_nodes_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.stack_nodes.id
}

resource "aws_security_group_rule" "eks_cluster_from_backend_nodes_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.backend_nodes.id
}

resource "aws_security_group_rule" "stack_nodes_from_backend_nodes_dns_tcp" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "tcp"
  security_group_id        = aws_security_group.stack_nodes.id
  source_security_group_id = aws_security_group.backend_nodes.id
}

resource "aws_security_group_rule" "stack_nodes_from_backend_nodes_dns_udp" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  security_group_id        = aws_security_group.stack_nodes.id
  source_security_group_id = aws_security_group.backend_nodes.id
}

resource "aws_security_group_rule" "backend_nodes_from_stack_nodes_dns_tcp" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "tcp"
  security_group_id        = aws_security_group.backend_nodes.id
  source_security_group_id = aws_security_group.stack_nodes.id
}

resource "aws_security_group_rule" "backend_nodes_from_stack_nodes_dns_udp" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  security_group_id        = aws_security_group.backend_nodes.id
  source_security_group_id = aws_security_group.stack_nodes.id
}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.name_prefix}-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_nodes" {
  name = "${var.name_prefix}-eks-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_nodes_worker" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_cni" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_ecr" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_extra" {
  for_each = toset(var.extra_node_role_policy_arns)

  role       = aws_iam_role.eks_nodes.name
  policy_arn = each.value
}

resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_public_access  = var.eks_endpoint_public_access
    endpoint_private_access = var.eks_endpoint_private_access
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  tags = merge(var.tags, {
    Name = var.eks_cluster_name
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
  ]
}

resource "aws_launch_template" "stack_nodes" {
  name_prefix = "${var.name_prefix}-stack-"

  vpc_security_group_ids = [aws_security_group.stack_nodes.id]

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "backend_nodes" {
  name_prefix = "${var.name_prefix}-backend-"

  vpc_security_group_ids = [aws_security_group.backend_nodes.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "stack" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.name_prefix}-stack"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.public_subnet_ids
  instance_types  = var.stack_node_instance_types

  scaling_config {
    desired_size = var.stack_node_desired_size
    min_size     = var.stack_node_min_size
    max_size     = var.stack_node_max_size
  }

  launch_template {
    id      = aws_launch_template.stack_nodes.id
    version = "$Latest"
  }

  labels = {
    role = "stack"
  }

  tags = var.tags
}

resource "aws_eks_node_group" "backend" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.name_prefix}-backend"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.backend_node_instance_types

  scaling_config {
    desired_size = var.backend_node_desired_size
    min_size     = var.backend_node_min_size
    max_size     = var.backend_node_max_size
  }

  launch_template {
    id      = aws_launch_template.backend_nodes.id
    version = "$Latest"
  }

  labels = {
    role = "backend"
  }

  tags = var.tags
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc_cni_addon_version
  service_account_role_arn    = var.vpc_cni_service_account_role_arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = var.enable_network_policy ? jsonencode({
    enableNetworkPolicy = "true"
  }) : null

  depends_on = [
    aws_eks_cluster.main,
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "coredns"
  addon_version               = var.coredns_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    nodeSelector = {
      role = "backend"
    }
  })

  depends_on = [
    aws_eks_cluster.main,
  ]
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]

  tags = var.tags
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

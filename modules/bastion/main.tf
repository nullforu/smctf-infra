check "bastion_subnet_index" {
  assert {
    condition     = (!var.create) || (var.subnet_index >= 0 && var.subnet_index < length(var.private_subnet_ids))
    error_message = "bastion_subnet_index is out of range for the configured private subnets."
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "bastion" {
  count = var.create ? 1 : 0
  name  = "${var.name_prefix}-bastion"

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

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  count      = var.create ? 1 : 0
  role       = aws_iam_role.bastion[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  count = var.create ? 1 : 0
  name  = "${var.name_prefix}-bastion"
  role  = aws_iam_role.bastion[0].name
}

resource "aws_security_group" "bastion" {
  count       = var.create ? 1 : 0
  name        = "${var.name_prefix}-bastion"
  description = "Bastion host security group (SSM only)"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-bastion"
  })
}

resource "aws_instance" "bastion" {
  count                       = var.create ? 1 : 0
  ami                         = var.ami_id != null ? var.ami_id : data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_ids[var.subnet_index]
  vpc_security_group_ids      = [aws_security_group.bastion[0].id]
  iam_instance_profile        = aws_iam_instance_profile.bastion[0].name
  associate_public_ip_address = false
  key_name                    = var.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-bastion"
  })
}

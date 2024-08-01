locals {
  security_group_name_prefix = "github-runner-sg"
  security_group_description = "Allow ssh ingress within vpc and all egress traffic"
  ubuntu_instance_name       = "github-runner"
  instance_type              = "t2.micro"
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_instance" "github_runner" {
  ami                    = var.ami_id
  instance_type          = local.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.github_runner.id]
  key_name               = var.key_name
  user_data = templatefile("${path.module}/scripts/self-hosted-runner.sh", {
    GITHUB_ORG  = var.github_org
    GITHUB_REPO = var.github_repo
    GITHUB_PAT  = var.github_token
  })

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = local.ubuntu_instance_name
  }
}

resource "aws_security_group" "github_runner" {
  name_prefix = local.security_group_name_prefix
  description = local.security_group_description
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.security_group_name_prefix
  }
}

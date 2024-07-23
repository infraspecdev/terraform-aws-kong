resource "aws_instance" "github_runner" {
  ami                    = var.ami_id
  instance_type          = local.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.github_runner.id]
  key_name               = var.key_name
  user_data = templatefile("${path.module}/scripts/self-hosted-runner.sh", {
    CONFIG_TOKEN = var.github_config_token
    CONFIG_URL   = var.github_config_url
  })
  tags = {
    Name = local.ubuntu_instance_name
  }
}

resource "aws_security_group" "github_runner" {
  name_prefix = local.security_group_name_prefix
  description = "Allow ssh ingress and all egress traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.region
}

# Docker secrets
resource "aws_ssm_parameter" "docker_username" {
  name  = "docker_username"
  type  = "SecureString"
  value = var.docker_username
}

resource "aws_ssm_parameter" "docker_password" {
  name  = "docker_password"
  type  = "SecureString"
  value = var.docker_password
}

# Config files as secrets
resource "aws_ssm_parameter" "config_file" {
  count = var.node_count

  name  = "config_${count.index}"
  type  = "SecureString"
  value = file("${path.module}/../../configs/encoded/${count.index}")
}

# EC2 instances
resource "aws_instance" "nodes" {
  instance_type = var.machine_type
  count         = var.node_count
  ami           = var.image

  subnet_id = aws_subnet.node_subnet.id
  vpc_security_group_ids = [aws_security_group.firewall.id]

  user_data = templatefile("${path.module}/startup_script.tpl", {
      region       = var.region
      repo_url 	   = var.repo_url
      repo_branch  = var.repo_branch
      node_id      = "${count.index}"
  })

  root_block_device {
    volume_size = 200
  }

  # IAM Role (equivalent to service account in GCP)
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  # Stopping condition
  disable_api_termination = var.is_production ? true : false

  tags = {
    Name = "${var.instance_name}-${count.index}"
  }
}

# Network Interface
resource "aws_network_interface" "node_nic" {
  count = var.node_count
  subnet_id = aws_subnet.node_subnet.id
  tags = {
    Name = "${var.instance_name}-${count.index}-nic"
  }
}

# External IP Allocations
resource "aws_eip" "static_ip" {
  count = var.node_count
  depends_on = [aws_internet_gateway.gateway]
  network_interface = aws_network_interface.node_nic[count.index].id
  tags = {
    Name = "${var.instance_name}-${count.index}-eip"
  }
}

# VPC
resource "aws_vpc" "node_vpc" {
  cidr_block = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.instance_name}"
  }
}

# Subnet (with IPv6 capabilities)
resource "aws_subnet" "node_subnet" {
  vpc_id = aws_vpc.node_vpc.id
  cidr_block = "${cidrsubnet(aws_vpc.node_vpc.cidr_block, 4, 1)}"
  map_public_ip_on_launch = true

  ipv6_cidr_block = "${cidrsubnet(aws_vpc.node_vpc.ipv6_cidr_block, 8, 1)}"
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "subnet-${var.instance_name}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.node_vpc.id

  tags = {
    Name = "igw-${var.instance_name}"
  }
}

# Route table to allow access to the Internet Gateway
resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.node_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gateway.id}"
    }

    route {
        ipv6_cidr_block = "::/0"
        gateway_id = "${aws_internet_gateway.gateway.id}"
    }

    tags = {
      Name = "rt-${var.instance_name}"
    }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "rta" {
    subnet_id      = "${aws_subnet.node_subnet.id}"
    route_table_id = "${aws_route_table.route_table.id}"
}

# Firewall
resource "aws_security_group" "firewall" {
  vpc_id = aws_vpc.node_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ip_allow_http_from_port
    to_port     = var.ip_allow_http_to_port
    protocol    = "tcp"
    cidr_blocks = var.ip_allow_http
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role and Instance Profile
resource "aws_iam_role" "ssm_role" {
  name = "${var.instance_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ],
  })

  tags = {
    Name = "${var.instance_name}-role"
  }
}

# Policy to allow pulling secrets
resource "aws_iam_policy" "ssm_policy" {
  name        = "ssm_policy"
  description = "Policy to allow access to SSM"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
        ],
        Effect = "Allow",
        Resource = "*"
      },
    ],
  })

  tags = {
    Name = "${var.instance_name}-ssm_policy"
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

# Attach role to profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.ssm_role.name
}

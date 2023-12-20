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

# Redis hostname
resource "aws_ssm_parameter" "redis_address" {
  name  = "redis_address"
  type  = "String"
  value = "${aws_elasticache_cluster.redis_cluster.cache_nodes[0].address}"
}

# Node IPs
resource "aws_ssm_parameter" "node_ips" {
  name  = "node_ips"
  type  = "String"
  value = join("\n", aws_eip.static_ip.*.public_ip)
}

# Redis cluster
resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = "redis-${var.instance_name}"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.redis_parameter_group.name
  engine_version       = "7.0"
  port                 = 6379

  security_group_ids = [aws_security_group.redis_security_group.id]
  subnet_group_name = aws_elasticache_subnet_group.redis_subnet_group.name
}

# Parameter group for Redis
resource "aws_elasticache_parameter_group" "redis_parameter_group" {
  name        = "redis-parameter-group-${var.instance_name}"
  family      = "redis7"
  description = "Redis parameter group"

  parameter {
    name  = "databases"
    value = "2"
  }

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }
}

# Subnet group for Redis
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name        = "redis-subnet-group-${var.instance_name}"
  description = "Subnet group for Redis"
  subnet_ids  = [aws_subnet.node_subnet.id]
}

# Security group for Redis
resource "aws_security_group" "redis_security_group" {
  name        = "allow-redis-${var.instance_name}"
  description = "Allow Redis traffic"
  vpc_id      = aws_vpc.node_vpc.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.node_subnet.cidr_block]
  }
}

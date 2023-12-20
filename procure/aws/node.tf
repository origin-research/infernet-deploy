# EC2 instances
resource "aws_instance" "nodes" {
  instance_type = var.machine_type
  count         = var.node_count
  ami           = var.image

  subnet_id = aws_subnet.node_subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]

  # Dependency is hidden in the startup script, so we need to specify it
  depends_on = [aws_elasticache_cluster.redis_cluster]

  user_data = templatefile("${path.module}/scripts/node.tpl", {
      region       = var.region
      repo_url 	   = var.repo_url
      repo_branch  = var.repo_branch
      node_id      = "${count.index}"
  })

  root_block_device {
    volume_size = 200
  }

  # IAM Role
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  # Stopping condition
  disable_api_termination = var.is_production ? true : false

  tags = {
    Name = "${var.instance_name}-${count.index}"
  }
}

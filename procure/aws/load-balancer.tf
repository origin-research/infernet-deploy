
# Load balancer
resource "aws_instance" "load_balancer" {
  ami             = "ami-07b36ea9852e986ad"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.node_subnet.id
  vpc_security_group_ids = [ aws_security_group.security_group.id ]

  # Startup script
  user_data = templatefile("${path.module}/scripts/lb.tpl", {region = var.region})

  root_block_device {
    volume_size = 200
  }

  # IAM Role
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  # Stopping condition
  disable_api_termination = var.is_production ? true : false

  tags = {
    Name = "${var.instance_name}-lb"
  }
}

# Reboot load balancer when node IPs change, so it can pick up new nodes and remove old ones
resource "null_resource" "update_lb" {
  triggers = {
    node_ips = join("\n", aws_eip.static_ip.*.public_ip)
  }

  provisioner "local-exec" {
    interpreter = [ "bash", "-c" ]
    command = "aws ec2 reboot-instances --instance-ids ${aws_instance.load_balancer.id} --region ${var.region}"
  }

  depends_on = [aws_instance.load_balancer, aws_ssm_parameter.node_ips]
}

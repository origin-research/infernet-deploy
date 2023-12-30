output "load_balancer_ip" {
  value = aws_eip.lb_eip.public_ip
}

output "node_ips" {
  value = aws_eip.static_ip[*].public_ip
}

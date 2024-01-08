output "load_balancer_ip" {
  value = aws_eip.lb_eip.public_ip
}

output "nodes" {
  value = [
    for i in range(length(aws_instance.nodes)): {
      id   = aws_instance.nodes[i].id
      ip   = aws_eip.static_ip[i].public_ip
    }
  ]
}

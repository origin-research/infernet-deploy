output "load_balancer_ip" {
  value = google_compute_address.lb_static_ip.address
}

output "node_ips" {
  value = google_compute_address.static-ip[*].address
}

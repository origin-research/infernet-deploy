output "load_balancer_ip" {
  value = google_compute_address.lb_static_ip.address
}

output "nodes" {
  value = [
    for i in range(length(google_compute_instance.nodes)): {
      name = google_compute_instance.nodes[i].name
      zone = google_compute_instance.nodes[i].zone
      project = google_compute_instance.nodes[i].project
      ip = google_compute_address.static-ip[i].address
    }
  ]
}
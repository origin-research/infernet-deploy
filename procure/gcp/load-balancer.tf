# Load balancer
resource "google_compute_instance" "load_balancer" {
  name         = "${var.instance_name}-lb"
  machine_type = "e2-micro"
  zone         = var.zone

  network_interface {
    network    = google_compute_network.node_net.id
    subnetwork = google_compute_subnetwork.node_subnet.id
    stack_type = "IPV4_IPV6"

    access_config {
      nat_ip = google_compute_address.lb_static_ip.address
      network_tier = "PREMIUM"
    }

    ipv6_access_config {
      network_tier  = "PREMIUM"
    }
  }

  metadata = {
    # Startup script
    startup-script = file("${path.module}/scripts/lb.sh", )

    # Node IPs
    node_ips = join("\n", [for ip in google_compute_address.static-ip : ip.address])
  
    # Docker credentials
    docker_username = var.docker_username
    docker_password = var.docker_password
  }

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size = 100
    }
  }

  # Disabled in production
  allow_stopping_for_update = var.is_production ? false : true
}

# Reset load balancer when node IPs change
resource "null_resource" "lb_restarter" {
  triggers = {
    node_ips = join(",", [for ip in google_compute_address.static-ip : ip.address])
  }

  provisioner "local-exec" {
    # Force reset load balancer, since updating its metadata does not
    command = "gcloud compute instances reset ${google_compute_instance.load_balancer.name} --zone=${google_compute_instance.load_balancer.zone}"
  }

  depends_on = [google_compute_instance.load_balancer]
}

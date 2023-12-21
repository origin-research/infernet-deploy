# GCE instances
resource "google_compute_instance" "nodes" {
  provider = google
  machine_type = "${var.machine_type}"

  count = var.node_count
  name = "${var.instance_name}-${count.index}"

  network_interface {
    network = google_compute_network.node_net.id
    subnetwork = google_compute_subnetwork.node_subnet.id
    stack_type = "IPV4_IPV6"

    access_config {
      nat_ip = google_compute_address.static-ip[count.index].address
      network_tier = "PREMIUM"
    }

    ipv6_access_config {
      network_tier  = "PREMIUM"
    }
  }

  metadata = {
    # Startup script
    startup-script = templatefile("${path.module}/scripts/node.tpl", {
      repo_url 	   = var.repo_url
      repo_branch  = var.repo_branch
    })

    # Secrets
    secret-config = file("${path.module}/../../configs/encoded/${count.index}")
    docker-username = var.docker_username
    docker-password = var.docker_password
  }

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size = 200
    }
  }

  # Disabled in production
  allow_stopping_for_update = var.is_production ? false : true
}

# VPC network
resource "google_compute_network" "node_net" {
  provider = google
  name = "net-${var.instance_name}"
  auto_create_subnetworks = false
}

# Subnet with IPv6 capabilities
resource "google_compute_subnetwork" "node_subnet" {
  provider = google
  name = "subnet-${var.instance_name}"
  network = google_compute_network.node_net.name
  ip_cidr_range = "10.0.0.0/8"
  stack_type = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL"
}

# Node ssh firewall
resource "google_compute_firewall" "allow-ssh" {
  provider = google
  name    = "allow-ssh-${var.instance_name}"
  network = google_compute_network.node_net.name

  allow {
    protocol = "icmp"
  }

  source_ranges = var.ip_allow_ssh

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Node http firewall
resource "google_compute_firewall" "allow-web" {
  name    = "allow-web-${var.instance_name}"
  network = google_compute_network.node_net.name

  # Always allow traffic from load balancer
  source_ranges = concat(var.ip_allow_http, [google_compute_address.lb_static_ip.address])

  allow {
    protocol = "tcp"
    ports    = var.ip_allow_http_ports
  }
}

# Redis firewall
resource "google_compute_firewall" "allow_redis" {
  name    = "allow-redis-${var.instance_name}"
  network = google_compute_network.node_net.name

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  source_ranges = [google_compute_subnetwork.node_subnet.ip_cidr_range]
}

#------------------------------------------------------------------------------

# Node external IPs
resource "google_compute_address" "static-ip" {
  provider = google
  count = var.node_count
  name = "${var.instance_name}-${count.index}-ip"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

# Load balancer external IP
resource "google_compute_address" "lb_static_ip" {
  name   = "${var.instance_name}-lb-ip"
  region = var.region
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

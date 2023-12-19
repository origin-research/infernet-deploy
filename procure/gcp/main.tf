terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.zone}"
}

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
    startup-script = templatefile("${path.module}/startup_script.tpl", {
      repo_url 	   = var.repo_url
      repo_branch  = var.repo_branch
    })

    # Secrets
    secret-config = file("${path.module}/../../configs/encoded/${count.index}")
    docker_username = var.docker_username
    docker_password = var.docker_password
  }

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size = 200
    }
  }

  # Disabled in production
  allow_stopping_for_update = var.is_production ? false : true

#------------------------------------------------------------------------------
  # confidential computing
  # NOTE: needs to be N2D or C2D instance if using confidential computing
  # https://cloud.google.com/confidential-computing/confidential-vm/docs/os-and-machine-type#machine-type

  confidential_instance_config {
    enable_confidential_compute = var.is_confidential_compute ? true : false
  }

  # required confidential compute
  scheduling {
    on_host_maintenance = var.is_confidential_compute ? "TERMINATE" : "MIGRATE"
  }
}
#------------------------------------------------------------------------------

# Network
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

# Allow SSH from only configured IPs
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

# Allow traffic from specific IP address and port
resource "google_compute_firewall" "allow-web" {
  name    = "allow-web-${var.instance_name}"
  network = google_compute_network.node_net.name

  source_ranges = var.ip_allow_http

  allow {
    protocol = "tcp"
    ports    = var.ip_allow_http_ports
  }
}

# Assign static external ip
resource "google_compute_address" "static-ip" {
  provider = google
  count = var.node_count
  name = "${var.instance_name}-${count.index}-ip"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

#------------------------------------------------------------------------------

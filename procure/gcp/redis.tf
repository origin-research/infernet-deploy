# Managed Redis instance
resource "google_redis_instance" "redis_instance" {
  name                = "redis-${var.instance_name}"
  tier                = "BASIC" # STANDARD_HA in production
  memory_size_gb      = 10
  authorized_network  = google_compute_network.node_net.name
  region              = var.region
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.12.0"
    }
  }
}
provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}
# create a vpc
resource "google_compute_network" "vpc_network" {
  name = var.vpc_name
  auto_create_subnetworks = false
}
# Create a  subnet
resource "google_compute_subnetwork" "my_subnet" {
  name          = var.subnet_name
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = var.cidr_range
  region        = var.region # Set your desired GCP region
}
# create firewall rule
resource "google_compute_firewall" "flask-api-lb-firewall" {
  name    = "flask-api-lb-firewall"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = [var.health_api_port]
  }

  source_ranges = [google_compute_global_forwarding_rule.my_forwarding_rule.ip_address,"35.191.0.0/16","130.211.0.0/22"]

  target_tags = [var.network_tag]
}

# Creating GCP VM
resource "google_compute_instance" "flask_api_vm" {
  name         = var.vm_name
  machine_type = var.vm_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.my_subnet.name
    access_config {
      // Ephemeral IP
    }
  }
  tags = [var.network_tag]
  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo docker run -d -p 8080:8082 srinadhnandagiri/flask-health-api:latest
  EOF
}
# Create instance group
resource "google_compute_instance_group" "flask_api_instance_group" {
  name        = var.ig_name
  zone        = var.zone
  description = "Flask api instance group"
  instances   = [google_compute_instance.flask_api_vm.self_link]
  named_port {
     name = "flask-api-named-port" 
     port = 8080 
        }
}
# Create health check
resource "google_compute_health_check" "flask_api_health_check" {
  name               = "tcp-8080-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  tcp_health_check {
    port = 8080
  }
}
# Create a Backend Service
resource "google_compute_backend_service" "flask_api_backend" {
  name = "flask-api-backend"
  port_name    = "flask-api-named-port"
  backend {
    group = google_compute_instance_group.flask_api_instance_group.self_link
  }

  health_checks = [google_compute_health_check.flask_api_health_check.self_link]
}
# Create forwarding rule
resource "google_compute_global_forwarding_rule" "my_forwarding_rule" {
  name       = "flask-api-forwarding-rule"
  target     = google_compute_target_http_proxy.flask_api_http_proxy.self_link
  port_range = "80"
}
# Create URL map
resource "google_compute_url_map" "flask_api_url_map" {
  name            = "flask-api-url-map"
  default_service = google_compute_backend_service.flask_api_backend.self_link
}

# Create target HTTP proxy
resource "google_compute_target_http_proxy" "flask_api_http_proxy" {
  name    = "flask-api-http-proxy"
  url_map = google_compute_url_map.flask_api_url_map.self_link
}

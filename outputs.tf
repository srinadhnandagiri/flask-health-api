output "lb_ip" {
  value = google_compute_global_forwarding_rule.my_forwarding_rule.ip_address
}

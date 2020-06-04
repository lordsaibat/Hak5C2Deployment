output "ip" {
 value = "${google_compute_instance.hak5-c2.network_interface.0.access_config.0.nat_ip}"
}

output "dns-name" {
 value= "${google_compute_instance.hak5-c2.network_interface.0.access_config.0.public_ptr_domain_name}"
}

output "ssh_user" {
  value = "root"
}
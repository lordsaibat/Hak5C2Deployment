output "ip" {
 value = "${digitalocean_droplet.hak5-c2.ipv4_address}"
}

output "ssh_user" {
  value = "root"
}
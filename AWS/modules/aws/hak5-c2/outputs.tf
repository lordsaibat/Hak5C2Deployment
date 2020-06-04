output "ip" {
  value = tostring([aws_instance.hak5-c2.public_ip][0])
}

output "dns-name" {
 value = tostring([aws_instance.hak5-c2.public_dns][0])
}


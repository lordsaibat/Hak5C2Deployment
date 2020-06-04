output "ip" {
 value = "${azurerm_linux_virtual_machine.main.public_ip_address}"
}

output "ssh_user" {
  value = "root"
}
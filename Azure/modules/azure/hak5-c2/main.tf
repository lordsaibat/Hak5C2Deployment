provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "hak5-resources"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "hak5-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "hak5-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  name                = "hak5-nic1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface" "internal" {
  name                      = "hak5-nic2"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "hak5" {
  name                = "hak5_ports"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = azurerm_network_interface.main.private_ip_address
  }

 security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "listenport"
    priority                   = 101
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = var.listenport
    destination_address_prefix = azurerm_network_interface.main.private_ip_address
  }

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "c2-ssh"
    priority                   = 110
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = var.c2ssh
    destination_address_prefix = azurerm_network_interface.main.private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.internal.id
  network_security_group_id = azurerm_network_security_group.hak5.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "hak5-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B1ms"
  admin_username                  = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.main.id,
    azurerm_network_interface.internal.id,
  ]
  
  admin_ssh_key {
    username = "adminuser"
    public_key = file("./ssh_keys/azure-user.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  
  provisioner "file" {
	  source      = "./files/"
    destination = "/tmp/"
		
        connection {
        type = "ssh"
        host = self.public_ip_address
        user = "adminuser"
        private_key = "${file("./ssh_keys/azure-user")}"
        }
  }

   provisioner "remote-exec" {
    inline = [
      "sudo apt-get update;sudo apt install unzip wget screen -y",
      "mkdir hak5;cd hak5",
      "wget https://c2.hak5.org/download/community",
      "unzip community",
    ]

    connection {
      host = self.public_ip_address
      type = "ssh"
      user = "adminuser"
      private_key = "${file("./ssh_keys/azure-user")}"
    }
  }

}
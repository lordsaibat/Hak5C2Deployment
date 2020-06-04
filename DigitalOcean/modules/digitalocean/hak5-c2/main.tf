provider "digitalocean" {
  token = file("do-creds.code")
}

resource "digitalocean_ssh_key" "hak5-key" {
  name       = "Hak5 C2 Key"
  public_key = file("./ssh_keys/do-keys.pub")
}

resource "digitalocean_droplet" "hak5-c2" {
  name         = "hak5-c2"
  image       = "ubuntu-18-04-x64"
  region       = "nyc1"
  size         = "s-1vcpu-1gb"
  ssh_keys = [digitalocean_ssh_key.hak5-key.fingerprint]

 //Upload all the directories on local host files
  provisioner "file" {
	  source      = "./files/"
    destination = "/tmp/"
		
        connection {
        type = "ssh"
        host = self.ipv4_address
        user = "root"
        private_key = "${file("./ssh_keys/do-keys")}"
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
      host = self.ipv4_address
      type = "ssh"
      user = "root"
      private_key = "${file("./ssh_keys/do-keys")}"
    }
  }
}


resource "digitalocean_firewall" "hak5-c2-firewall-ports" {
  name    = "hak5-c2-firewall-ports"
  droplet_ids = [digitalocean_droplet.hak5-c2.id]

  inbound_rule {
    port_range = "22"
    protocol = "tcp"
    source_addresses = ["0.0.0.0/0"]
  }
  
  dynamic "inbound_rule"{
   for_each = var.ports
      content{
        port_range = inbound_rule.value
        protocol = "tcp"
        source_addresses = ["0.0.0.0/0"]
      }
  }
}


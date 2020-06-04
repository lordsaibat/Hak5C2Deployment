provider "google" {
  project = var.project
  credentials = file("gcloud.json")
}

resource "google_compute_instance" "hak5-c2" {
  name         = "hak5-c2"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = google_compute_network.default.name

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
   ssh-keys = "guser:${file("./ssh_keys/gkeys.pub")}"
 }

 //Upload all the directories on local host files
  provisioner "file" {
	  source      = "./files/"
    destination = "/tmp/"
		
        connection {
        type = "ssh"
        host = self.network_interface.0.access_config.0.nat_ip
        user = "guser"
        private_key = "${file("./ssh_keys/gkeys")}"
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
      host = self.network_interface.0.access_config.0.nat_ip
      type = "ssh"
      user = "guser"
      private_key = "${file("./ssh_keys/gkeys")}"
    }
  }
}

resource "google_compute_firewall" "hak5-c2-firewall-hhtp" {
  name    = "hak5-c2-firewall-http"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = var.ports
  }
   source_ranges = ["0.0.0.0/0"]
   direction = "INGRESS"

  source_tags = ["hak5-c2"]
}

resource "google_compute_firewall" "hak5-c2-firewall-ssh" {
  name    = "hak5-c2-firewall-ssh"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["22" ]
  }
   source_ranges = ["0.0.0.0/0"] 
   direction = "INGRESS"

  source_tags = ["hak5-c2"]
}


resource "google_compute_network" "default" {
  name = "hak5-c2-network"
}
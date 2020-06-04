terraform {
  required_version = ">= 0.11.0"
}

provider "aws" {
  region = var.region
  version = "2.7"
}

data "aws_region" "current" {}

resource "aws_key_pair" "hak5-c2" {
  key_name = "hak5_host_key"
  public_key = file("./ssh_keys/hak5_keys.pub")
 }

 resource "aws_instance" "hak5-c2" {
   
  tags = {
    Name = "hak5-c2"
  }

  ami = var.amis[data.aws_region.current.name]
  instance_type = var.instance_type
  key_name = aws_key_pair.hak5-c2.key_name
  vpc_security_group_ids = [aws_security_group.hak5-c2.id]
  subnet_id = var.subnet_id
  associate_public_ip_address = true
 
 //Upload all the directories on local host files
  provisioner "file" {
	  source      = "./files/"
    destination = "/tmp/"
		
        connection {
        type = "ssh"
        host = aws_instance.hak5-c2.public_ip
        user = "ec2-user"
        private_key = file("./ssh_keys/hak5_keys")
        }
 }
   
//Install any dependancies
provisioner "remote-exec" {
    inline = [
      "sudo apt-get update;sudo apt install unzip wget screen -y",
      "mkdir hak5;cd hak5",
      "wget https://c2.hak5.org/download/community",
      "unzip community",
    ]
   
    connection {
        type = "ssh"
        host = aws_instance.hak5-c2.public_ip
        user = "ec2-user"
        private_key = file("./ssh_keys/hak5_keys")
    }
  }
 }
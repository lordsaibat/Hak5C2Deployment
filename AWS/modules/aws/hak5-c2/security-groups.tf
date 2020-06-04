terraform {
  required_version = ">= 0.11.0"
}

resource "aws_security_group" "hak5-c2" {
  name = "hak5-c2"
  description = "Hak5-c2 security groups by Terraform"
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    //cidr_blocks = ["${data.external.get_public_ip.result["ip"]}/32"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress"{
   for_each = var.ports
      content{
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
  }
  
   egress {
    //Communications outbound
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}
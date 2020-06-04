 resource "null_resource" "C2_run"{
    //depends_on = [module.google_compute_instance.http-c2, module.google_compute_instance.dns-c2]
   //connection
    connection {
        type = "ssh"
        host = var.listenip
        user = "ec2-user"
        private_key = "${file("./ssh_keys/hak5_keys")}"
    }
    provisioner "remote-exec" {
    inline = [
     "cd ./hak5;sudo screen -S hak5 -d -m nohup /home/ec2-user/hak5/c2_community-linux-64 -hostname ${var.hostname} -listenport ${var.listenport}", //http
     // "cd ./hak5;sudo screen -S hak5 -d -m nohup /home/ec2-user/hak5/c2_community-linux-64 -hostname ${var.hostname} -listenport ${var.listenport} -https", //https 
     "sleep 30",
    ]
  }
 }
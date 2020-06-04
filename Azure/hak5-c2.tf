terraform {
  required_version = ">= 0.11.0"
}

module "hak5-c2" {
    source = "./modules/azure/hak5-c2"
    location = "East US"
    listenport = "80"
    c2ssh = "2022"
}

module "C2-run" {
  source = "./modules/null_resource"
   //hostname = "example.com"
  hostname = "${module.hak5-c2.ip}"
  listenip = "${module.hak5-c2.ip}"
  listenport = "80"
}


output "hak5-c2-ip" {
  value = "${module.hak5-c2.ip}"
}

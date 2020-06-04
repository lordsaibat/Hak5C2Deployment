terraform {
 required_version = ">= 0.11.0"
}

module "create_vpc" {
 source = "./modules/aws/create-vpc"
}

module "hak5-c2" {
 source = "./modules/aws/hak5-c2"
 vpc_id = module.create_vpc.vpc_id
 subnet_id = module.create_vpc.subnet_id
 ports =  ["80","2022"]
}

module "C2-run" {
 source = "./modules/null_resource"
 //hostname = "example.com"
 hostname = "${module.hak5-c2.ip}"
 listenip = "${module.hak5-c2.ip}"
 listenport =  "80"
}

output "hak5-c2-ip" {
  value = "${module.hak5-c2.ip}"
}

output "hak5-c2-dns" {
  value = "${module.hak5-c2.dns-name}"
}

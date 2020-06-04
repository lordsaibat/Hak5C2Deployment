variable "subnet_id" {}

variable "vpc_id" {}

variable "instance_type" {
  default = "t2.small"
  
}
variable "region" {
  default = "us-east-1"
}

variable "amis" {
  default = {
   "us-east-1" =  "ami-0c11557d0e4e9c896"
  }
}

variable "ports" {
  type = list(string)
  default = ["80","443","2022"]
}
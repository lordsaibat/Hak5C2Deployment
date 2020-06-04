variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "listenport" {
  default = "80"
}

variable "c2ssh" {
   default = "2022"
}
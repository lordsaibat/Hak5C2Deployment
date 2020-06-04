
variable "machine_type" {
  default = "n1-standard-1"
}

variable "project" {
  default = "project"
}

variable "ports" {
  type = list(number)
  default = [443,2022]
}
###network vars
variable "vpc_name" {
  type        = string
  default     = "netology-vpc-01"
  description = "VPC network"
}

variable "subnet-names" {
  type = list(string)
  default = [ "public-a-01", "public-b-01", "public-d-01" ]
}

variable "subnet-zones" {
  type = list(string)
  default = [ "ru-central1-a", "ru-central1-b", "ru-central1-d" ]
}

variable "cidr-ip" {
  type = map(list(string))
  default = {
    "cidr" = [ "10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24" ]
  }
}

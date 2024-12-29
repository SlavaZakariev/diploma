variable "staic-ip" {
  type = map(list(string))
  default = {
    "ip" = [ "10.10.1.11", "10.10.2.12", "10.10.3.13" ]
  }
}

variable "vms_resources" {
  type            = map(map(number))
  default         = {
    node  = {
      cores       = 2
      ram         = 4
      fraction    = 20
    }
  }
}

variable "vm_cpu_id_v3" {
  type        = string
  default     = "standard-v3"
  description = "cpu id v1"
}

variable "vm_os" {
  type        = string
  default     = "fd85u0rct32prepgjlv0" # Ubuntu 22.04 LTS
  description = "os version"
}

variable "disk_type" {
  type        = string
  default     = "network-ssd"
}

variable "disk_size" {
  type        = string
  default     = "12"
}

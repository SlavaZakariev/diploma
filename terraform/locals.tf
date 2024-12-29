locals {
  metadata = {
    serial-port-enable = 1
    ssh-keys = "metadata:${file("./metadata.yaml")}"
 }
}

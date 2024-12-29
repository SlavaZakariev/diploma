resource "yandex_compute_instance" "k8s" {
  count                     = 3
  platform_id               = var.vm_cpu_id_v3
  name                      = "node-${count.index}"
  hostname                  = "node-${count.index}"
  zone                      = "${var.subnet-zones[count.index]}"
  allow_stopping_for_update = true
  labels                    = {index = "${count.index}"}

  resources {
    cores         = var.vms_resources.node.cores
    memory        = var.vms_resources.node.ram
    core_fraction = var.vms_resources.node.fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_os
      name     = "node-${count.index}"
      type     = var.disk_type
      size     = var.disk_size
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.subnet-zones[count.index].id}"
    ip_address = "${var.staic-ip.ip[count.index]}"
    nat        = true
  }

  scheduling_policy {preemptible = true} # Прерываение ВМ

  metadata = local.metadata # SSH ключ
}

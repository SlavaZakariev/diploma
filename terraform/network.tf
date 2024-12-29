resource "yandex_vpc_network" "network-01" {
  name = var.vpc_name
 }

resource "yandex_vpc_subnet" "subnet-zones" {
  count          = 3
  name           = "${var.subnet-names[count.index]}"
  zone           = "${var.subnet-zones[count.index]}"
  network_id     = yandex_vpc_network.network-01.id
  v4_cidr_blocks = [ "${var.cidr-ip.cidr[count.index]}" ]
}

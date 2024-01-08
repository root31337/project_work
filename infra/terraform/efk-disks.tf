resource "yandex_compute_disk" "data-efk-cluster-0" {

  name = "data-efk-cluster-0"
  type = "network-hdd"
  zone = var.zone
  size = "10"
}

resource "yandex_compute_disk" "data-efk-cluster-1" {

  name = "data-efk-cluster-1"
  type = "network-hdd"
  zone = var.zone
  size = "10"
}

resource "yandex_compute_disk" "data-efk-cluster-2" {

  name = "data-efk-cluster-2"
  type = "network-hdd"
  zone = var.zone
  size = "10"
}


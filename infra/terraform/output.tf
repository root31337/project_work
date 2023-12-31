output "gitlab" {
  value = yandex_vpc_address.gitlabIP.external_ipv4_address.0.address
  }

output "cluster_external_v4_endpoint" {
  value = yandex_kubernetes_cluster.k8s-cluster.master.0.external_v4_endpoint
}

output "data-efk-cluster-0" {
  value = yandex_compute_disk.data-efk-cluster-0.id
}

output "data-efk-cluster-1" {
  value = yandex_compute_disk.data-efk-cluster-1.id
}

output "data-efk-cluster-2" {
  value = yandex_compute_disk.data-efk-cluster-2.id
}

resource "local_file" "tf_ansible_vars_file" {
  content = <<-DOC
    data_efk_cluster_0: ${yandex_compute_disk.data-efk-cluster-0.id}
    data_efk_cluster_1: ${yandex_compute_disk.data-efk-cluster-1.id}
    data_efk_cluster_2: ${yandex_compute_disk.data-efk-cluster-2.id}
    DOC
  filename = "../ansible/playbooks/tf_ansible_vars_file.yaml"
}



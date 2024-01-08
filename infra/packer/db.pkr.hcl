source "yandex" "ubuntu16" {
  service_account_key_file = "./packer/key.json"
  folder_id = "b1g0bgapni0osi095ffl"
  use_ipv4_nat = true
  preemptible = true
  source_image_family = "ubuntu-1604-lts"
  image_name = "mongodbdb-base-${formatdate("MM-DD-YYYY", timestamp())}"
  image_family = "mongodb-base"
  ssh_username = "ubuntu"
  platform_id = "standard-v1"
  subnet_id = "e9b24d2brea26rc2tc3a"
}

build {
  sources = ["source.yandex.ubuntu16"]

  provisioner "shell" {
    inline = [
    "echo Waiting for apt-get to finish...",
    "a=1; while [ -n \"$(pgrep apt-get)\" ]; do echo $a; sleep 1s; a=$(expr $a + 1); done",
    "echo Done."
    ]
  }


  provisioner "shell" {

    
    name            = "mongodb"
    script          = "./packer/scripts/install_mongodb.sh"
    execute_command = "sudo {{.Path}}"
  }
}

variable "source_image_family" {
  type = string
  default = "ubuntu-1604-lts"
}

variable "service_account_key_file" {
  type = string
  default = "./packer/key.json"
}

variable "image-id {
  type = string
  default = "fd8fp6gf9d7trfyroheub"
}

variable "folder_id" {
  type = string
  default = "b1g0bgapni0osi095ffl"
}

variable "zone" {
  type = string
  default = "ru-central1-a"
}


variable "subnet_id" {
  type = string
  default = "e9b24d2brea26rc2tc3a"
}
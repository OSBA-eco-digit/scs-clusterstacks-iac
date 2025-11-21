variable "OS_CLOUD" {
  type    = string
  default = "openstack"
}

variable "KEYPAIR_PATH" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "INSTANCE_FLAVOR_NAME" {
  type    = string
  default = "SCS-4V-8-20"
}

variable "INSTANCE_IMAGE_NAME" {
  type    = string
  default = "Ubuntu 22.04"
}

variable "PUBLIC_NETWORK_ID" {
  type = string
}

variable "PUBLIC_NETWORK_NAME" {
  type    = string
  default = "public-network"
}

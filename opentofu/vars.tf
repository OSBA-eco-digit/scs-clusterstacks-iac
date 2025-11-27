#
# DEFAULTS
#

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

variable "NETWORK_SUBNET4_CIDR" {
  type    = string
  default = "192.168.96.0/24"
}

variable "NETWORK_SUBNET6_CIDR" {
  type    = string
  default = "fd00:192:168:96::/64"
}

variable "INSTANCE_IMAGE_NAME" {
  type    = string
  default = "Ubuntu 22.04"
}

variable "RANDOM_PASSWD_LENGTH" {
  type    = number
  default = 32
}
######################################################################

#
# VARIABLES TO BE SET
#

variable "PUBLIC_NETWORK_ID" {
  type = string
}

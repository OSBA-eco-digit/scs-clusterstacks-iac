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
  default = "SCS-2V-4-20s"
}

variable "NETWORK_SUBNET4_CIDR" {
  type    = string
  default = "192.168.96.0/24"
}

variable "NETWORK_SUBNET4_NAMESERVERS" {
  type    = list(any)
  default = ["174.138.21.128", "188.166.206.224"]
}

variable "NETWORK_SUBNET6_CIDR" {
  type    = string
  default = "fd00:192:168:96::/64"
}

variable "NETWORK_SUBNET6_NAMESERVERS" {
  type    = list(any)
  default = ["2620:fe::fe"]
}


variable "INSTANCE_IMAGE_NAME" {
  type    = string
  default = "Ubuntu 24.04"
}

variable "INSTANCE_USER_NAME" {
  type    = string
  default = "ubuntu"
}

variable "RANDOM_PASSWD_LENGTH" {
  type    = number
  default = 32
}

variable "SSH_AGENT_ENABLE" {
  type    = bool
  default = true
}
######################################################################

#
# VARIABLES TO BE SET
#

variable "PUBLIC_NETWORK_ID" {
  type = string
}

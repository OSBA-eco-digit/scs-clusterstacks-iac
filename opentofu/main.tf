terraform {
  required_providers {
    openstack = { source = "terraform-provider-openstack/openstack" }
    random    = { source = "hashicorp/random" }
  }
}

provider "openstack" {
  cloud = var.OS_CLOUD
}

resource "random_password" "random_passwd" {
  length  = var.RANDOM_PASSWD_LENGTH
  special = true
}

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_keypair_v2
resource "openstack_compute_keypair_v2" "my_keypair" {
  name       = "my_keypair"
  public_key = file(var.KEYPAIR_PATH)
}

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/data-sources/networking_network_v2
data "openstack_networking_network_v2" "public_network" {
  network_id = var.PUBLIC_NETWORK_ID
  external   = true
}

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/data-sources/networking_subnet_ids_v2
data "openstack_networking_subnet_ids_v2" "public_network_subnet4" {
  network_id = var.PUBLIC_NETWORK_ID
  ip_version = 4
  tags       = ["external", "public"]
}

# data "openstack_networking_subnet_ids_v2" "public_network_subnet6" {
#   network_id = var.PUBLIC_NETWORK_ID
#   ip_version = 6
#   tags       = ["external", "public"]
# }

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_router_v2
resource "openstack_networking_router_v2" "my_router" {
  name                = "my_router"
  external_network_id = var.PUBLIC_NETWORK_ID
}

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_router_interface_v2
resource "openstack_networking_router_interface_v2" "my_router_interface4" {
  router_id = openstack_networking_router_v2.my_router.id
  subnet_id = openstack_networking_subnet_v2.my_network_subnet4.id
}

# resource "openstack_networking_router_interface_v2" "my_router_interface6" {
#   router_id = openstack_networking_router_v2.my_router.id
#   subnet_id = data.openstack_networking_subnet_ids_v2.public_network_subnet6.id
# }

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_port_v2
resource "openstack_networking_port_v2" "my_instance_port4" {
  name       = "my_instance_port4"
  network_id = openstack_networking_network_v2.my_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.my_network_subnet4.id
  }
}

resource "openstack_networking_port_v2" "my_instance_port6" {
  name       = "my_instance_port6"
  network_id = openstack_networking_network_v2.my_network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.my_network_subnet6.id
  }
}

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_floatingip_associate_v2
resource "openstack_networking_floatingip_associate_v2" "my_floatingip4_associate" {
  # fixed_ip  = openstack_networking_floatingip_v2.my_floatingip4.fixed_ip
  floating_ip = openstack_networking_floatingip_v2.my_floatingip4.address
  port_id     = openstack_networking_port_v2.my_instance_port4.id
  # depends_on = [
  #   openstack_networking_floatingip_v2.my_floatingip4,
  #   openstack_networking_router_interface_v2.my_router_interface4,
  #   openstack_networking_router_v2.my_router
  # ]
}

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_floatingip_v2
resource "openstack_networking_floatingip_v2" "my_floatingip4" {
  pool      = data.openstack_networking_network_v2.public_network.name
  subnet_id = data.openstack_networking_subnet_ids_v2.public_network_subnet4.id
  tags      = ["external", "public"]
}

# resource "openstack_networking_floatingip_v2" "my_floatingip6" {
#   pool    = data.openstack_networking_network_v2.public_network.name
#   subnet_id = data.openstack_networking_subnet_ids_v2.public_network_subnet6.id
#   tags      = ["external", "public"]
# }

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_network_v2
resource "openstack_networking_network_v2" "my_network" {
  name                  = "my_network"
  admin_state_up        = true
  port_security_enabled = true
}

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_subnet_v2
resource "openstack_networking_subnet_v2" "my_network_subnet4" {
  name       = "my_network_subnet4"
  network_id = openstack_networking_network_v2.my_network.id
  cidr       = var.NETWORK_SUBNET4_CIDR
  ip_version = 4
}

resource "openstack_networking_subnet_v2" "my_network_subnet6" {
  name       = "my_network_subnet6"
  network_id = openstack_networking_network_v2.my_network.id
  cidr       = var.NETWORK_SUBNET6_CIDR
  ip_version = 6
}

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_instance_v2
resource "openstack_compute_instance_v2" "my_instance" {
  admin_pass      = random_password.random_passwd.result
  flavor_name     = var.INSTANCE_FLAVOR_NAME
  image_name      = var.INSTANCE_IMAGE_NAME
  key_pair        = "my_keypair"
  name            = "my_instance"
  security_groups = ["default"]

  network {
    name = "my_instance_network4"
    port = openstack_networking_port_v2.my_instance_port4.id
  }

  lifecycle {
    ignore_changes = [admin_pass]
  }
}

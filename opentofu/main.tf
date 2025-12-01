terraform {
  required_providers {
    openstack = { source = "terraform-provider-openstack/openstack" }
    random    = { source = "hashicorp/random" }
    local     = { source = "hashicorp/local" }
    null      = { source = "hashicorp/null" }
  }
}

provider "openstack" {
  cloud = var.OS_CLOUD
}

resource "random_password" "random_passwd" {
  length      = var.RANDOM_PASSWD_LENGTH
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
  special     = true
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

data "openstack_networking_subnet_ids_v2" "public_network_subnet6" {
  network_id = var.PUBLIC_NETWORK_ID
  ip_version = 6
  tags       = ["external", "public"]
}

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_floatingip_v2
resource "openstack_networking_floatingip_v2" "my_floatingip4" {
  pool       = data.openstack_networking_network_v2.public_network.name
  subnet_ids = data.openstack_networking_subnet_ids_v2.public_network_subnet4.ids
}

# resource "openstack_networking_floatingip_v2" "my_floatingip6" {
#   pool    = data.openstack_networking_network_v2.public_network.name
#   subnet_id = data.openstack_networking_subnet_ids_v2.public_network_subnet6.id
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

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_port_v2
resource "openstack_networking_port_v2" "my_network_port4" {
  name       = "my_network_port4"
  network_id = openstack_networking_network_v2.my_network.id
  fixed_ip {
    ip_address = openstack_networking_floatingip_v2.my_floatingip4.fixed_ip
    subnet_id  = openstack_networking_subnet_v2.my_network_subnet4.id
  }
  depends_on = [
    openstack_networking_subnet_v2.my_network_subnet4
  ]
}

# resource "openstack_networking_port_v2" "my_network_port6" {
#   name       = "my_network_port6"
#   network_id = openstack_networking_network_v2.my_network.id
#   fixed_ip {
#     ip_address = openstack_networking_floatingip_v2.my_floatingip6.fixed_ip
#     subnet_id  = openstack_networking_subnet_v2.my_network_subnet6.id
#   }
#   depends_on = [
#     openstack_networking_subnet_v2.my_network_subnet6
#   ]
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

resource "openstack_networking_router_interface_v2" "my_router_interface6" {
  router_id = openstack_networking_router_v2.my_router.id
  subnet_id = openstack_networking_subnet_v2.my_network_subnet6.id
}

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_floatingip_associate_v2
resource "openstack_networking_floatingip_associate_v2" "my_floatingip4_associate" {
  floating_ip = openstack_networking_floatingip_v2.my_floatingip4.address
  port_id     = openstack_networking_port_v2.my_network_port4.id

  depends_on = [
    openstack_networking_port_v2.my_network_port4,
    openstack_networking_router_interface_v2.my_router_interface4,
    openstack_networking_subnet_v2.my_network_subnet4
  ]
}

### https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_instance_v2
resource "openstack_compute_instance_v2" "my_instance" {
  admin_pass  = random_password.random_passwd.result
  flavor_name = var.INSTANCE_FLAVOR_NAME
  image_name  = var.INSTANCE_IMAGE_NAME
  key_pair    = openstack_compute_keypair_v2.my_keypair.name
  name        = "my_instance"

  security_groups = ["default"]

  network {
    name = openstack_networking_network_v2.my_network.name
    uuid = openstack_networking_network_v2.my_network.id
  }

  connection {
    type     = "ssh"
    user     = var.INSTANCE_USER_NAME
    host     = openstack_networking_floatingip_v2.my_floatingip4.address
    agent    = var.SSH_AGENT_ENABLE
    password = random_password.random_passwd.result
  }

  lifecycle {
    ignore_changes = [admin_pass]
  }
}
################################################################################

resource "local_file" "my_ansible_inventory" {
  content              = "my_instance ansible_host=${openstack_networking_floatingip_v2.my_floatingip4.address} ansible_user=${var.INSTANCE_USER_NAME}"
  directory_permission = "0755"
  filename             = "../ansible/inventory_${var.OS_CLOUD}.ini"
  file_permission      = "0644"
}

resource "null_resource" "my_provisioner" {
  triggers = { my_instance_public_addr4 = openstack_networking_floatingip_v2.my_floatingip4.address }
  provisioner "local-exec" {
    # command = "sleep 13; ANSIBLE_ROLES_PATH=${var.ARP} ansible-playbook -i ../ansible/inventory_${var.OS_CLOUD}.ini ../ansible/playbooks/scs-cluster-stack.yml"
    command = "date >/tmp/date.txt"
  }
}

output "my_instance_public_addr4" { value = openstack_networking_floatingip_v2.my_floatingip4.address }

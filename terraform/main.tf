# Une VM par entrée de var.vms, clonée depuis le template cloud-init.
module "vm" {
  source   = "./modules/proxmox-vm"
  for_each = var.vms

  name            = each.key
  vm_id           = each.value.vm_id
  node_name       = var.node_name
  template_id     = var.template_id
  datastore_id    = var.datastore_id
  cores           = each.value.cores
  memory_mb       = each.value.memory_mb
  disk_gb         = each.value.disk_gb
  bridge          = var.lan_bridge
  vlan_id         = each.value.vlan_id
  ipv4_address    = each.value.ipv4
  ipv4_gateway    = var.gateway
  ssh_public_keys = var.ssh_public_keys
  tags            = each.value.tags
}

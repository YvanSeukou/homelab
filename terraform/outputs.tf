output "vms" {
  description = "VM créées : ID Proxmox et adresse IP"
  value = {
    for name, vm in module.vm : name => {
      vm_id = vm.vm_id
      ipv4  = vm.ipv4_address
    }
  }
}

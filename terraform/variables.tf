variable "proxmox_endpoint" {
  description = "URL de l'API Proxmox, par exemple https://192.168.10.2:8006/"
  type        = string
}

variable "proxmox_api_token" {
  description = "Jeton d'API Proxmox au format utilisateur@realm!id=secret (à mettre dans terraform.tfvars, jamais dans Git)"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Accepter le certificat auto-signé de Proxmox (lab uniquement)"
  type        = bool
  default     = true
}

variable "node_name" {
  description = "Nom du nœud Proxmox"
  type        = string
  default     = "pve"
}

variable "template_id" {
  description = "ID du template cloud-init (ex. Debian 12 ou Ubuntu 24.04) à cloner"
  type        = number
  default     = 9000
}

variable "datastore_id" {
  description = "Stockage Proxmox des disques"
  type        = string
  default     = "local-lvm"
}

variable "lan_bridge" {
  description = "Bridge Proxmox relié à l'interface LAN d'OPNsense"
  type        = string
  default     = "vmbr1"
}

variable "gateway" {
  description = "Passerelle des VM (interface LAN / VLAN d'OPNsense)"
  type        = string
  default     = "10.10.20.1"
}

variable "ssh_public_keys" {
  description = "Clés SSH publiques injectées par cloud-init"
  type        = list(string)
}

variable "vms" {
  description = "VM à créer : une entrée par machine"
  type = map(object({
    vm_id     = number
    cores     = number
    memory_mb = number
    disk_gb   = number
    ipv4      = string
    vlan_id   = optional(number)
    tags      = optional(list(string), [])
  }))

  default = {
    "srv-docker" = {
      vm_id     = 120
      cores     = 2
      memory_mb = 4096
      disk_gb   = 40
      ipv4      = "10.10.20.20/24"
      vlan_id   = 20
      tags      = ["docker", "terraform"]
    }
    "srv-runner" = {
      vm_id     = 121
      cores     = 2
      memory_mb = 2048
      disk_gb   = 20
      ipv4      = "10.10.20.21/24"
      vlan_id   = 20
      tags      = ["ci", "terraform"]
    }
  }
}

variable "name" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "node_name" {
  type = string
}

variable "template_id" {
  type = number
}

variable "datastore_id" {
  type = string
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory_mb" {
  type    = number
  default = 2048
}

variable "disk_gb" {
  type    = number
  default = 20
}

variable "bridge" {
  type = string
}

variable "vlan_id" {
  type    = number
  default = null
}

variable "ipv4_address" {
  description = "Adresse en notation CIDR, ou \"dhcp\""
  type        = string
}

variable "ipv4_gateway" {
  type    = string
  default = null
}

variable "ci_user" {
  type    = string
  default = "admin"
}

variable "ssh_public_keys" {
  type = list(string)
}

variable "tags" {
  type    = list(string)
  default = []
}

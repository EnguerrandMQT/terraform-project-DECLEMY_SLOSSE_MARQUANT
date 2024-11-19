variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "location" {
  type        = string
  description = "The Azure location for the VNet."
}

variable "app_name" {
  type        = string
  description = "The application name used as a prefix for the VNet."
}

variable "address_space" {
  type        = list(string)
  description = "The address space for the virtual network."
}

variable "dns_servers" {
  type        = list(string)
  description = "The DNS servers for the virtual network."
  nullable    = true
  default     = null
}

variable "subnet" {
  type = list(object({
    name             = string
    address_prefixes = list(string)
  }))
  description = "The list of subnets to create within the VNet."
}

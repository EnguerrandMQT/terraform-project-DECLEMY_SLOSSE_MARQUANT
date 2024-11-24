variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure location for the resources."
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "Configuration des sous-réseaux avec délégations et points de service"
  type = map(object({
    subnet_prefix        = string
    service_endpoints    = optional(list(string), [])
    delegation = optional(object({
      name = string
      service_delegation_name = string
      actions = list(string)
    }), null)
  }))
}

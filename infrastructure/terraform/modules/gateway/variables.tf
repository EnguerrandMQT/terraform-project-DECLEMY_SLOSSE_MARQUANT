variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure location for the resources."
  type        = string
}

variable "subnet" {
  description = "ID of the public IP."
  type        = string
}

variable "public_ip_name" {
  description = "Name of the public IP."
  type        = string
}

variable "application_gateway_name" {
  description = "Name of the application gateway."
  type        = string
}

variable "sku_name" {
  description = "SKU name for the application gateway."
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "SKU tier for the application gateway."
  type        = string
  default     = "Standard_v2"
}

variable "sku_capacity" {
  description = "Capacity for the application gateway."
  type        = number
  default     = 1
}

variable "backend_fqdn" {
  description = "FQDN for the backend pool."
  type        = string
}

variable "domain_name_label" {
  description = "Domain name label for the public IP."
  type        = string 
}
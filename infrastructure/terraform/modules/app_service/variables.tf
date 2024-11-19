variable "app_name" {
  type        = string
  default     = "app_service"
  description = "Name of the application"
}

variable "location" {
  type        = string
  default     = "francecentral"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  default     = "terraform-project-DECLEMY_SLOSSE_MARQUANT"
  description = "Resource group name for the project"
}

variable "pricing_plan" {
  type        = string
  default     = "F1"
  description = "SKU for the pricing plan"

  validation {
    condition = contains([
      "B1", "B2", "B3", "D1", "F1", "I1", "I2", "I3", "I1v2",
      "I2v2", "I3v2", "I4v2", "I5v2", "I6v2", "P1v2", "P2v2",
      "P3v2", "P0v3", "P1v3", "P2v3", "P3v3", "P1mv3", "P2mv3",
      "P3mv3", "P4mv3", "P5mv3", "S1", "S2", "S3", "SHARED",
      "EP1", "EP2", "EP3", "FC1", "WS1", "WS2", "WS3", "Y1"
    ], var.pricing_plan)
    error_message = "The pricing plan must be a valid SKU. See https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan#sku_name."
  }
}

variable "docker_image" {
  type = string
  nullable = false
}

variable "docker_registry_url" {
  type = string
  default = "https://index.docker.io"
}

variable "app_settings" {
  description = "App service settings (list of environment variables)"
  default = {}
  type = map(string)
}
variable "github_handle" {
  type        = string
  nullable    = false
  description = "Your GitHub username"
}

variable "subscription_id" {
  type        = string
  nullable    = false
  description = <<EOT
Your Azure subscription ID

To retrieve it:
az login --use-device-code
az account show --query='id' --output=tsv
EOT
}

variable "email_address" {
  type        = string
  nullable    = false
  description = "Email address used by azure."
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
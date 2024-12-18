variable "location" {
  type        = string
  default     = "francecentral"
  description = "Location of the resources"
}

variable "resource_group_name" {
  type        = string
  default     = "resourcegroup-dms"
  description = "Name of the resource group in which all resource are grouped"
}

variable "domain_name_label" {
  type        = string
  default     = "dms-api"
  description = "Label of the domain name"
  
}

############
# Identity #
############


variable "github_handle" {
  type        = string
  nullable    = false
  description = "Your GitHub username (not your email, your @username)"
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
  description = "Your JUNIA email address. Example: firstname.lastname@*.junia.com"
}

variable "docker_registry_server_password" {
  type = string
  sensitive = true
  description = "Password to connect to the Docker registry"
  default = null
}

############
# Database #
############


variable "database_server_name" {
  type        = string
  default     = null
  description = "Name of the database server. Example: playground-computing-handlegithub"
}

variable "database_name" {
  type        = string
  default     = null
  description = "Name for the database within the server"
}

variable "database_username" {
  type        = string
  default     = null
  description = "Administrator username for the database"
}

variable "database_password" {
  type        = string
  default     = null
  sensitive   = true
  description = <<EOT
"Administrator password for the database"

The password must be at least 8 characters and at most 128 characters.
The password must contain characters from three of the following categories:
– English uppercase letters
- English lowercase letters
- numbers (0-9)
- non-alphanumeric characters (!, $, #, %, etc.)
EOT
}

resource "random_password" "database_password" {
  length      = 24
  min_special = 1
  min_numeric = 2
  min_lower   = 2
  min_upper   = 2
}


#############
# New relic #
#############


variable "new_relic_licence_key" {
  type        = string
  sensitive   = true
  default     = null
  description = "New Relic license key"
}


###########
# Storage #
###########


variable "storage_name" {
  type        = string
  default     = null
  description = "Name of the storage account"
}

##########
# Locals #
##########


locals {
  database = {
    # server_name = var.database_server_name != null ? var.database_server_name : "playground-computing-${var.github_handle}"
    # name        = var.database_name != null ? var.database_name : var.github_handle
    # username    = var.database_username != null ? var.database_username : var.github_handle
    server_name = "playground-computing-dms"
    name        = "dmsdatabase"
    username    = "dms"
    password    = var.database_password != null ? var.database_password : random_password.database_password.result
  }

  storage = {
    # name = var.storage_name != null ? var.storage_name : var.github_handle
    name = "storageblobdms"
  }
}

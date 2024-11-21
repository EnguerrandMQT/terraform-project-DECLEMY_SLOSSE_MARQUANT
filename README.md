# Terraform project: Deployment of an api on Azure Cloud

This repository holds a Terraform stack to build an example api on Azure Cloud.

## Maintainers

[Maxime DECLEMY](maxime.declemy@student.junia.com)  
[Enguerrand MARQUANT](enguerrand.marquant@student.junia.com)  
[Paul SLOSSE](paul.slosse@student.junia.com)

## Summary

This stack is deploying on **Azure**:
* A resource group
* A gateway
* An app service
* A blob storage
* A PostgreSQL flexible server
* A virtual network

This repository is also using Github Actions workflow to:
* Build and deploy a GithHub Container Registry
* (WIP) Deploy the newly built container on the Azure App Service
* Run python tests on the API when a pull request is opened
* (WIP) Run terraform tests on the infrastructure when a pull request is opened

## How-to build

This stack uses the **local** mode of Terraform. We assume that you already have Terraform installed on your machine.

It is built from the CLI.

You first need to install [postgreSQL](https://www.postgresql.org/download/)  
Then you need to install the Azure CLI for [Linux](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
) or [Windows](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
).

Connect to your azure account with the command `az login`.

The `plan` and `apply` Terrafom commands have to be launched locally.

Summary of the commands to run:
```shell
$ az login
$ terraform init
$ terraform plan
$ terraform apply
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.3 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.0.2 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.9.0 |
| <a name="provider_github"></a> [github](#provider\_github) | 6.3.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_storage"></a> [api\_storage](#module\_api\_storage) | ./modules/storage | n/a |
| <a name="module_database"></a> [database](#module\_database) | ./modules/database | n/a |
| <a name="module_examples_api_service"></a> [examples\_api\_service](#module\_examples\_api\_service) | ./modules/app_service | n/a |
| <a name="module_gateway"></a> [gateway](#module\_gateway) | ./modules/gateway | n/a |
| <a name="module_virtual_network"></a> [virtual\_network](#module\_virtual\_network) | ./modules/virtual_network | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.ressourcegroup-dms](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_password.database_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azuread_user.user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [github_user.user](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name for the database within the server | `string` | `null` | no |
| <a name="input_database_password"></a> [database\_password](#input\_database\_password) | "Administrator password for the database"<br/><br/>The password must be at least 8 characters and at most 128 characters.<br/>The password must contain characters from three of the following categories:<br/>– English uppercase letters<br/>- English lowercase letters<br/>- numbers (0-9)<br/>- non-alphanumeric characters (!, $, #, %, etc.) | `string` | `null` | no |
| <a name="input_database_server_name"></a> [database\_server\_name](#input\_database\_server\_name) | Name of the database server. Example: playground-computing-handlegithub | `string` | `null` | no |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | Administrator username for the database | `string` | `null` | no |
| <a name="input_email_address"></a> [email\_address](#input\_email\_address) | Your JUNIA email address. Example: firstname.lastname@*.junia.com | `string` | n/a | yes |
| <a name="input_github_handle"></a> [github\_handle](#input\_github\_handle) | Your GitHub username (not your email, your @username) | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the resources | `string` | `"francecentral"` | no |
| <a name="input_new_relic_licence_key"></a> [new\_relic\_licence\_key](#input\_new\_relic\_licence\_key) | New relic licence key used by the app service container to publish logs & metrics.<br/><br/>See documentation https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/<br/><br/>To retrieve it, go to https://send.bitwarden.com/#bX2ytcWjUUSvJrIAAXayPA/RVbs3obbFkjeybNQuzrBCw<br/>The Bitwarden password will be displayed in class. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group in which all resource are grouped | `string` | `"ressourcegroup-dms"` | no |
| <a name="input_storage_name"></a> [storage\_name](#input\_storage\_name) | Name of the storage account | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Your Azure subscription ID<br/><br/>To retrieve it:<br/>az login --use-device-code<br/>az account show --query='id' --output=tsv | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api"></a> [api](#output\_api) | URL to access the HTTP API |
| <a name="output_database"></a> [database](#output\_database) | Database connection information |
| <a name="output_gateway_ip"></a> [gateway\_ip](#output\_gateway\_ip) | Public IP address of the API gateway |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | Principal ID of the API service |
| <a name="output_storage"></a> [storage](#output\_storage) | URL to access the storage account |
<!-- END_TF_DOCS -->

## Development details

We use the [terraform-docs](https://github.com/terraform-docs/terraform-docs/) to generate the terraform documentation.
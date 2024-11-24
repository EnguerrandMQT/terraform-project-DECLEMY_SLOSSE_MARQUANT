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
* A public IP address
* An app service and its plan
* A blob storage
* A PostgreSQL flexible server
* An endpoint to access the database
* Two virtual networks and their subnets
* A private DNS zone

The following image shows the architecture of the stack:
[![Architecture]](./architecture.png)

This repository is also using Github Actions workflow to:
* Build and deploy a GithHub Container Registry
* Deploy the newly built container on the Azure App Service
* Run python tests on the API when a pull request is opened
* Run terraform validate on the infrastructure when a pull request is opened

### Nota Bene
To build and populate the database, we use your local public IP address. You can access the database and the blob without going through the gateway. However, the API is only accessible through the gateway.
For other IPs, the accesses are restricted, they can only access the database and the blob storage through the gateway.

## How-to build

This stack uses the **local** mode of Terraform. We assume that you already have Terraform installed on your machine.

It is built from the CLI.

You first need to install [postgreSQL](https://www.postgresql.org/download/)  
Then you need to install the Azure CLI for [Linux](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
) or [Windows](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
).

Connect to your azure account with the command `az login`.

The `plan` and `apply` Terrafom commands have to be launched locally.

You can create a file `terraform.tfvars` in the terraform folder to avoid filling the prompt each time you apply.

This stack integrates new relic monitoring. If you want to use it, you need to create an account on [New Relic](https://newrelic.com/signup) and get an INGEST LICENSE key. You can then add it to the `terraform.tfvars` file.

When the stack is deployed, you can also automatically deploy the API on the Azure App Service. To do so :
* Create a new repository on GitHub.
* Create a new secret in the repository settings with the name `AZURE_WEBAPP_PUBLISH_PROFILE` and the value of the publish profile of the App Service (you can find it in the Azure portal).
* Create a personal access token on GitHub with the `repo` scope and add it to the `terraform.tfvars` file under the name `docker_registry_server_password`.
* A Github Action will be triggered when the stack is deployed. It will build the Docker image and push it to the GitHub Container Registry. The image will then be deployed on the Azure App Service.


Your final `terraform.tfvars` file should look like this:
```shell
email_address = "xx.xx@*.junia.com"
github_handle = <your_github_username in lowercase>
subscription_id = <az account show --query='id' --output=tsv>
new_relic_licence_key = "eu01xxxx"
docker_registry_server_password = "ghp_xx"
```

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
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.5 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_storage"></a> [api\_storage](#module\_api\_storage) | ./modules/storage | n/a |
| <a name="module_database"></a> [database](#module\_database) | ./modules/database | n/a |
| <a name="module_examples_api_service"></a> [examples\_api\_service](#module\_examples\_api\_service) | ./modules/app_service | n/a |
| <a name="module_gateway"></a> [gateway](#module\_gateway) | ./modules/gateway | n/a |
| <a name="module_virtual_network_gateway"></a> [virtual\_network\_gateway](#module\_virtual\_network\_gateway) | ./modules/virtual_network | n/a |
| <a name="module_virtual_network_storage"></a> [virtual\_network\_storage](#module\_virtual\_network\_storage) | ./modules/virtual_network | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.resourcegroup-dms](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_password.database_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azuread_user.user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [github_user.user](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/user) | data source |
| [http_http.ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name for the database within the server | `string` | `null` | no |
| <a name="input_database_password"></a> [database\_password](#input\_database\_password) | "Administrator password for the database"<br/><br/>The password must be at least 8 characters and at most 128 characters.<br/>The password must contain characters from three of the following categories:<br/>– English uppercase letters<br/>- English lowercase letters<br/>- numbers (0-9)<br/>- non-alphanumeric characters (!, $, #, %, etc.) | `string` | `null` | no |
| <a name="input_database_server_name"></a> [database\_server\_name](#input\_database\_server\_name) | Name of the database server. Example: playground-computing-handlegithub | `string` | `null` | no |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | Administrator username for the database | `string` | `null` | no |
| <a name="input_docker_registry_server_password"></a> [docker\_registry\_server\_password](#input\_docker\_registry\_server\_password) | Password to connect to the Docker registry | `string` | `null` | no |
| <a name="input_domain_name_label"></a> [domain\_name\_label](#input\_domain\_name\_label) | Label of the domain name | `string` | `"dms-api"` | no |
| <a name="input_email_address"></a> [email\_address](#input\_email\_address) | Your JUNIA email address. Example: firstname.lastname@*.junia.com | `string` | n/a | yes |
| <a name="input_github_handle"></a> [github\_handle](#input\_github\_handle) | Your GitHub username (not your email, your @username) | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the resources | `string` | `"francecentral"` | no |
| <a name="input_new_relic_licence_key"></a> [new\_relic\_licence\_key](#input\_new\_relic\_licence\_key) | New Relic license key | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group in which all resource are grouped | `string` | `"resourcegroup-dms"` | no |
| <a name="input_storage_name"></a> [storage\_name](#input\_storage\_name) | Name of the storage account | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Your Azure subscription ID<br/><br/>To retrieve it:<br/>az login --use-device-code<br/>az account show --query='id' --output=tsv | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api"></a> [api](#output\_api) | Public IP address of the API gateway |
| <a name="output_app_service"></a> [app\_service](#output\_app\_service) | URL to access the HTTP API |
| <a name="output_database"></a> [database](#output\_database) | Database connection information |
| <a name="output_storage"></a> [storage](#output\_storage) | URL to access the storage account |
<!-- END_TF_DOCS -->

## File structure

```
terraform/
├── main.tf
├── modules/
│   ├── app_service/
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── database/
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── gateway/
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── storage/
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   └── virtual_network/
│       ├── main.tf
│       ├── output.tf
│       └── variables.tf
├── output.tf
├── provider.tf
├── terraform.tfvars
└── variables.tf
```

## Development details

We use the [terraform-docs](https://github.com/terraform-docs/terraform-docs/) to generate the terraform documentation.
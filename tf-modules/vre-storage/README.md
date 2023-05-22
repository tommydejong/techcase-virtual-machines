# Terraform module for the core workspaces resources for a VRE on Microsoft Azure

This is the module repository that contains the definition of the Azure VRE resources that create the base infrastructure, plus all stateful resources. This includes, but is not limited to the resource group, storage account and data storage solutions.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.vre-workspace-rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.vre-workspace-sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_share.vre-data-file-share](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azFileStorage"></a> [azFileStorage](#input\_azFileStorage) | Set to true to enable creation of a storage file share on the workspace storage account | `bool` | `"false"` | no |
| <a name="input_region"></a> [region](#input\_region) | The Azure region the VRE should be placed in. | `string` | `"westeurope"` | no |
| <a name="input_researchdrive"></a> [researchdrive](#input\_researchdrive) | Set to true to mount an existing Researchdrive instance | `bool` | `"false"` | no |
| <a name="input_storageAccessTier"></a> [storageAccessTier](#input\_storageAccessTier) | Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot. | `string` | `"Hot"` | no |
| <a name="input_storageAccountTier"></a> [storageAccountTier](#input\_storageAccountTier) | Defines the Tier to use for this storage account. Valid options are Standard and Premium. Defaults to Standard. | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key value pair to tag all resources | `map(string)` | `{}` | no |
| <a name="input_trimmed_workspaceName"></a> [trimmed\_workspaceName](#input\_trimmed\_workspaceName) | n/a | `any` | n/a | yes |
| <a name="input_workspaceName"></a> [workspaceName](#input\_workspaceName) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_master_storage_account_name"></a> [master\_storage\_account\_name](#output\_master\_storage\_account\_name) | The name of the master storage account |
| <a name="output_master_workspace_rg"></a> [master\_workspace\_rg](#output\_master\_workspace\_rg) | The RG name for the workspace |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The access key for accessing this storage account |
<!-- END_TF_DOCS -->
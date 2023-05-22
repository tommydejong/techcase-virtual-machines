# Terraform module for a Virtual Research Environment (VRE) on Microsoft Azure

This is the module repository that contains the definition of an Azure VRE.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ansible"></a> [ansible](#provider\_ansible) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ansible_host.vre-ansible](https://registry.terraform.io/providers/hashicorp/ansible/latest/docs/resources/host) | resource |
| [azurerm_key_vault.vre-kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault.vre-mgmt-kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.vre-kv-ap](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.vre-kv-vm-ap](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.vre-mgmt-kv-ap](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_key.azure-diskencryption-key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_secret.vre-rd-key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.vre-rd-user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_linux_virtual_machine.vre-vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.vre-nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_security_group.vre-nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.gitlab-runner-ssh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.vre-allow_edu_vpn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.vre-allow_hva_vpn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.vre-allow_uva_vpn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.vre-firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.vre-remote_access_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.vre-pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.vre-vm-access-sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_subnet.vre-subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.vre-nsg_to_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_machine_extension.vre-vm-win-antimalware](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.vre-vm-win-bitlocker-encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.vre-vm-win-init](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_network.vre-vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_windows_virtual_machine.vre-vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [null_resource.ip-address-access-to-sa](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.vre-subnet-access-to-sa](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_pet.vre-identifier](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_string.vm_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.vre-ssh-key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_public_ip_prefix.trusted_public_ip_prefix](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip_prefix) | data source |
| [azurerm_resource_group.vre-workspace-rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_shared_image_version.packer-shared-image](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/shared_image_version) | data source |
| [azurerm_storage_account.vre-workspace-sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowEduVPN"></a> [allowEduVPN](#input\_allowEduVPN) | n/a | `bool` | `false` | no |
| <a name="input_allowHvaVPN"></a> [allowHvaVPN](#input\_allowHvaVPN) | n/a | `bool` | `false` | no |
| <a name="input_allowUvaVPN"></a> [allowUvaVPN](#input\_allowUvaVPN) | Access and firewall rules | `bool` | `false` | no |
| <a name="input_autoShutdownSchedule"></a> [autoShutdownSchedule](#input\_autoShutdownSchedule) | Define an AutoShutDownSchedule here. Example value: "20:00->08:00, Saturday, Sunday". More info at: https://github.com/tomasrudh/AutoShutdownSchedule#schedule-tag-examples | `string` | `""` | no |
| <a name="input_azFileStorage"></a> [azFileStorage](#input\_azFileStorage) | Set to true to enable creation of a storage file share on the workspace storage account | `bool` | `"false"` | no |
| <a name="input_customDomainName"></a> [customDomainName](#input\_customDomainName) | Provide a custom domain name for the VRE. The value will be added to the public IP address, and will result in the following domain name: `<value>`.`<location>`.cloudapp.azure.com | `string` | `""` | no |
| <a name="input_diskSkuMapping"></a> [diskSkuMapping](#input\_diskSkuMapping) | The types of disks that are available in Azure. This maps potential values in the frontend to their respective size in Azure. | `map` | <pre>{<br>  "HDD": "Standard_LRS",<br>  "Premium": "Premium_LRS",<br>  "SSD": "StandardSSD_LRS",<br>  "Ultra": "UltraSSD_LRS"<br>}</pre> | no |
| <a name="input_firewallRules"></a> [firewallRules](#input\_firewallRules) | A list of firewall rules to add to the security group. Each rule should be a map of values to add | `any` | `{}` | no |
| <a name="input_jcApiKey"></a> [jcApiKey](#input\_jcApiKey) | The API key of the JumpCloud instance this VRE is added to. | `string` | `""` | no |
| <a name="input_osType"></a> [osType](#input\_osType) | The OS type of the VRE. Must be either windows or linux. | `string` | n/a | yes |
| <a name="input_osdiskSize"></a> [osdiskSize](#input\_osdiskSize) | The size in GB of the OS Disk. | `number` | `128` | no |
| <a name="input_osdiskSku"></a> [osdiskSku](#input\_osdiskSku) | The SKU used for the OS Disk. Possible values: Standard\_LRS, Premium\_LRS, StandardSSD\_LRS or UltraSSD\_LRS | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_projectName"></a> [projectName](#input\_projectName) | n/a | `any` | n/a | yes |
| <a name="input_rDriveKey"></a> [rDriveKey](#input\_rDriveKey) | The key that will be used to connect to ResearchDrive. | `string` | `""` | no |
| <a name="input_rDriveUser"></a> [rDriveUser](#input\_rDriveUser) | The username/e-mail address that will be used to connect to ResearchDrive. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The Azure region the VRE should be placed in. | `string` | `"westeurope"` | no |
| <a name="input_remoteAccessRules"></a> [remoteAccessRules](#input\_remoteAccessRules) | A list of IP addresses that should have access to the VRE. | `any` | `{}` | no |
| <a name="input_researchdrive"></a> [researchdrive](#input\_researchdrive) | Set to true to connect an existing ResearchDrive to this VRE. If true, be sure to specify a rDriveKey and rDriveUser | `bool` | `"false"` | no |
| <a name="input_software"></a> [software](#input\_software) | A list of software packages to install. Example: ["rstudio", "qdaminer"] | <pre>list(object({<br>    name    = string<br>    version = string<br>  }))</pre> | `[]` | no |
| <a name="input_storageAccountName"></a> [storageAccountName](#input\_storageAccountName) | The existing storage account that should be linked to this VRE instance | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key value pair to tag all resources | `map(string)` | `{}` | no |
| <a name="input_trimmed_workspaceName"></a> [trimmed\_workspaceName](#input\_trimmed\_workspaceName) | n/a | `any` | n/a | yes |
| <a name="input_vmSize"></a> [vmSize](#input\_vmSize) | The size of the VM used for the VRE. To get a list of available VM sizes use az vm list-sizes --location "westeurope" -otable. Example values: Standard\_NC6\_promo, Standard\_B4ms | `string` | `""` | no |
| <a name="input_vmSizeMapping"></a> [vmSizeMapping](#input\_vmSizeMapping) | The size of the VM used for the VRE. This maps potential values in the frontend to their respective size in Azure. | `map` | <pre>{<br>  "GPU": "Standard_NC6_Promo",<br>  "Medium": "Standard_D8s_v5",<br>  "Memory": "Standard_E8ds_v5",<br>  "Small": "Standard_B4ms"<br>}</pre> | no |
| <a name="input_workspaceName"></a> [workspaceName](#input\_workspaceName) | n/a | `any` | n/a | yes |
| <a name="input_workspaceRG"></a> [workspaceRG](#input\_workspaceRG) | The workspace resource group where the VRE should be created in | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the created key vault |
| <a name="output_vre_private_ssh_key"></a> [vre\_private\_ssh\_key](#output\_vre\_private\_ssh\_key) | The private SSH key to access the VRE |
<!-- END_TF_DOCS -->
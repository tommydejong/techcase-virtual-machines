output "master_workspace_rg" {
  description = "The RG name for the workspace"
  value       = azurerm_resource_group.vre-workspace-rg.name
}

output "master_storage_account_name" {
  description = "The name of the master storage account"
  value       = azurerm_storage_account.vre-workspace-sa.name
}

# output "master_applied_configs_container_name" {
#   description = "The name of the container in the master storage account where applied vre-config.yml files should go"
#   value       = azurerm_storage_container.vre-tf-applied-configs-container.name
# }

output "primary_access_key" {
  description = "The access key for accessing this storage account"
  value       = azurerm_storage_account.vre-workspace-sa.primary_access_key
  sensitive   = true
}
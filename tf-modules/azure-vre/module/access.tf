# Give the VM's Managed Identity access to the key vault in order to retrieve secrets
resource "azurerm_key_vault_access_policy" "vre-kv-vm-ap" {
  key_vault_id       = azurerm_key_vault.vre-kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = var.osType == "windows" ? azurerm_windows_virtual_machine.vre-vm[0].identity.0.principal_id : azurerm_linux_virtual_machine.vre-vm[0].identity.0.principal_id
  key_permissions    = ["get", "list", ]
  secret_permissions = ["get", "list", ]
}

# Give the VM's Managed Identity access to the storage account in order to retrieve access keys for the Azure File Share
resource "azurerm_role_assignment" "vre-vm-access-sa" {
  count = var.azFileStorage ? 1 : 0

  scope                = data.azurerm_storage_account.vre-workspace-sa.id
  role_definition_name = "Reader and Data Access"
  principal_id         = var.osType == "windows" ? azurerm_windows_virtual_machine.vre-vm[0].identity.0.principal_id : azurerm_linux_virtual_machine.vre-vm[0].identity.0.principal_id
}
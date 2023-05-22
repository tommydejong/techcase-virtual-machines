# Create the Azure File Share here so that it is not accidentally removed.
# Unlike the azure-vre module, this vre-storage module has a prevent_destroy configuration in all VRE's
resource "azurerm_storage_share" "vre-data-file-share" {
  count                = var.azFileStorage ? 1 : 0
  name                 = "vredata"
  storage_account_name = azurerm_storage_account.vre-workspace-sa.name
  quota                = 5120 # 5 TB, default value
}
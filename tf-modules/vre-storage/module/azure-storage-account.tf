# Storage Account
resource "azurerm_storage_account" "vre-workspace-sa" {
  name                = "${var.trimmed_workspaceName}sa"
  resource_group_name = azurerm_resource_group.vre-workspace-rg.name
  location            = var.region
  tags                = var.tags

  account_kind             = "StorageV2"
  account_tier             = var.storageAccountTier
  account_replication_type = "LRS"
  access_tier              = var.storageAccessTier

  enable_https_traffic_only = "true"
  allow_blob_public_access  = "false"
  min_tls_version           = "TLS1_2"

  network_rules {
    default_action             = "Allow" # Change this when issues with storage account firewall are fixed
    ip_rules                   = ["87.208.38.6", "45.94.174.33"] # Home & Office
    bypass                     = ["AzureServices", "Logging", "Metrics"]
  }

  blob_properties {
    delete_retention_policy {
      days = 14
    }
  }
}

# We cannot do this here when storage account firewall is active. See https://github.com/hashicorp/terraform-provider-azurerm/issues/2977
# It is now handled in the upload_vre_config_blob_v2.sh script in the misc-helpers repo. This should be changed later.

# # Blob for applied configs
# resource "azurerm_storage_container" "vre-tf-applied-configs-container" {
#   name                  = "vre-applied-configs"
#   storage_account_name  = azurerm_storage_account.vre-workspace-sa.name
#   container_access_type = "private"
# }
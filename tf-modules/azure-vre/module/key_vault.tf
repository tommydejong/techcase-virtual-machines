# Key Vault
resource "azurerm_key_vault" "vre-mgmt-kv" {
  name                = "${random_pet.vre-identifier.id}-mgmt-kv"
  location            = var.region
  resource_group_name = data.azurerm_resource_group.vre-workspace-rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enabled_for_deployment          = true
  enable_rbac_authorization       = false

  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  sku_name                   = "standard"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["87.208.38.6", "45.94.174.33"] # Home & Office
  }
  tags = var.tags
}

# Key Vault
resource "azurerm_key_vault" "vre-kv" {
  name                = "${random_pet.vre-identifier.id}-kv"
  location            = var.region
  resource_group_name = data.azurerm_resource_group.vre-workspace-rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enabled_for_deployment          = true
  enable_rbac_authorization       = false

  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  sku_name                   = "standard"

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.vre-subnet.id]
    ip_rules                   = ["87.208.38.6", "45.94.174.33"] # Home & Office
  }
  tags = var.tags
}

# Assign access to VRE service principal to the created Key Vault using the current Azure config
resource "azurerm_key_vault_access_policy" "vre-mgmt-kv-ap" {
  key_vault_id       = azurerm_key_vault.vre-mgmt-kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  key_permissions    = ["create", "get", "list", "delete", "purge", ]
  secret_permissions = ["set", "get", "delete", "list", "purge", ]

  depends_on = [
    azurerm_key_vault.vre-mgmt-kv
  ]
}

# Assign access to VRE service principal to the created Key Vault using the current Azure config
resource "azurerm_key_vault_access_policy" "vre-kv-ap" {
  key_vault_id       = azurerm_key_vault.vre-kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  key_permissions    = ["create", "get", "list", "delete", "purge", ]
  secret_permissions = ["set", "get", "delete", "list", "purge", ]

  depends_on = [
    azurerm_key_vault.vre-kv
  ]
}
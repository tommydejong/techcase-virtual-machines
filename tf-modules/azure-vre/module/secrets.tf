resource "tls_private_key" "vre-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create VM password
resource "random_string" "vm_password" {
  length           = 12
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  special          = true
  override_special = "/@$"
}

# Add the ResearchDrive username and password to the created Key Vault when this is configured under 'Software'
resource "azurerm_key_vault_secret" "vre-rd-key" {
  count           = var.researchdrive ? 1 : 0
  name            = "rdrive-key"
  value           = var.rDriveKey
  key_vault_id    = azurerm_key_vault.vre-kv.id
  expiration_date = "2022-12-31T00:00:00Z"
  content_type    = "20ch key"

  depends_on = [
    azurerm_key_vault_access_policy.vre-kv-ap
  ]
}

resource "azurerm_key_vault_secret" "vre-rd-user" {
  count           = var.researchdrive ? 1 : 0
  name            = "rdrive-username"
  value           = var.rDriveUser
  key_vault_id    = azurerm_key_vault.vre-kv.id
  expiration_date = "2022-12-31T00:00:00Z"
  content_type    = "E-mail Address"

  depends_on = [
    azurerm_key_vault_access_policy.vre-kv-ap
  ]
}
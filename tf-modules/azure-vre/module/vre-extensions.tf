# Custom script extension to initialize disks, install Jumpcloud and SSH key in Windows
resource "azurerm_virtual_machine_extension" "vre-vm-win-init" {
  count = var.osType == "windows" ? 1 : 0

  name               = "Initialize-Windows-VRE"
  virtual_machine_id = azurerm_windows_virtual_machine.vre-vm[0].id

  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  tags = var.tags

  # Works only if container custom-script-extension has read permission by anonymous (access level container)
  settings = <<SETTINGS
      {
        "fileUris": [
              "https://vretfcoresa.blob.core.windows.net/software/initialize-jc-sshkey_v2.ps1"
            ],
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File initialize-jc-sshkey_v2.ps1 -publicKey \"${base64encode(tls_private_key.vre-ssh-key.public_key_openssh)}\" -jcApiKey \"${var.jcApiKey}\""
      }
  SETTINGS
}

# Use cloud-init for Linux machines

# === Enable OS-level Azure Disk Encryption using VM Extension === #

# Generate encryption keys for OS-level Azure Disk Encryption
resource "azurerm_key_vault_key" "azure-diskencryption-key" {
  name            = "${random_pet.vre-identifier.id}-vm-azure-diskencryption-key"
  key_vault_id    = azurerm_key_vault.vre-mgmt-kv.id
  expiration_date = "2021-12-31T00:00:00Z"

  key_type = "RSA"
  key_size = 4096
  key_opts = [
    "decrypt",
    "encrypt",
    "wrapKey",
    "unwrapKey",
  ]

  depends_on = [
    azurerm_key_vault_access_policy.vre-mgmt-kv-ap
  ]
}

# Install VM Extensions
# Linux disk encryption using DMCrypt
resource "azurerm_virtual_machine_extension" "vre-vm-linux-dmcrypt-encryption" {
  count = var.osType == "linux" ? 1 : 0

  name               = "DiskEncryption"
  virtual_machine_id = azurerm_linux_virtual_machine.vre-vm[0].id

  publisher            = "Microsoft.Azure.Security"
  type                 = "AzureDiskEncryptionForLinux"
  type_handler_version = "1.1"

  tags = var.tags

  settings = <<SETTINGS
    {
        "EncryptionOperation": "EnableEncryption",
        "KeyVaultURL": "${azurerm_key_vault.vre-kv.vault_uri}",
        "KeyVaultResourceId": "${azurerm_key_vault.vre-kv.id}",
        "KeyEncryptionKeyURL": "${azurerm_key_vault_key.azure-diskencryption-key.id}",
        "KekVaultResourceId": "${azurerm_key_vault.vre-kv.id}",
        "KeyEncryptionAlgorithm": "RSA-OAEP",
        "VolumeType": "All"
    }
    SETTINGS

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

  depends_on = [
    azurerm_key_vault_access_policy.vre-kv-ap
  ]
}

# Microsoft Antimalware Extension
resource "azurerm_virtual_machine_extension" "vre-vm-win-antimalware" {
  count = var.osType == "windows" ? 1 : 0

  name               = "IaaSAntimalware"
  virtual_machine_id = azurerm_windows_virtual_machine.vre-vm[0].id

  publisher            = "Microsoft.Azure.Security"
  type                 = "IaaSAntimalware"
  type_handler_version = "1.3"

  tags = var.tags

  settings = <<SETTINGS
    {
        "AntimalwareEnabled": true,
        "RealtimeProtectionEnabled": "true",
        "ScheduledScanSettings": {
            "isEnabled": "true",
            "day": "1",
            "time": "120",
            "scanType": "Quick"
            },
        "Exclusions": {
            "Extensions": "",
            "Paths": "",
            "Processes": ""
            }
    }
  SETTINGS

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

  depends_on = [
    azurerm_virtual_machine_extension.vre-vm-win-antimalware
  ]
}

# Windows disk encryption using BitLocker
# resource "azurerm_virtual_machine_extension" "vre-vm-win-bitlocker-encryption" {
#   count = var.osType == "windows" ? 1 : 0

#   name               = "DiskEncryption"
#   virtual_machine_id = azurerm_windows_virtual_machine.vre-vm[0].id

#   publisher            = "Microsoft.Azure.Security"
#   type                 = "AzureDiskEncryption"
#   type_handler_version = "2.2"

#   tags = var.tags

#   settings = <<SETTINGS
#     {
#         "EncryptionOperation": "EnableEncryption",
#         "KeyVaultURL": "${azurerm_key_vault.vre-mgmt-kv.vault_uri}",
#         "KeyVaultResourceId": "${azurerm_key_vault.vre-mgmt-kv.id}",
#         "KeyEncryptionKeyURL": "${azurerm_key_vault_key.azure-diskencryption-key.id}",
#         "KekVaultResourceId": "${azurerm_key_vault.vre-mgmt-kv.id}",
#         "KeyEncryptionAlgorithm": "RSA-OAEP",
#         "VolumeType": "All"
#     }
#     SETTINGS

#   lifecycle {
#     ignore_changes = [
#       tags,
#     ]
#   }

#   depends_on = [
#     azurerm_key_vault_access_policy.vre-mgmt-kv-ap,
#     azurerm_virtual_machine_extension.vre-vm-win-antimalware
#   ]
# }
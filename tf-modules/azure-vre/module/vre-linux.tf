## New resources

# Linux

resource "azurerm_linux_virtual_machine" "vre-vm" {
  count                 = var.osType == "linux" ? 1 : 0 # make this dynamic when we want to make the amount of VM instances variable
  name                  = "${random_pet.vre-identifier.id}-vm"
  location              = var.region
  resource_group_name   = data.azurerm_resource_group.vre-workspace-rg.name
  network_interface_ids = [azurerm_network_interface.vre-nic.id]
  size                  = local.vmSize

  tags = merge(var.tags,
    {
      "packerImage"          = "${local.sharedImageName}-${data.azurerm_shared_image_version.packer-shared-image.name}"
      "AutoShutdownSchedule" = var.autoShutdownSchedule
    }
  )

  provision_vm_agent         = true
  allow_extension_operations = true

  computer_name  = local.computerName
  admin_username = local.adminUsername
  admin_ssh_key {
    username   = local.adminUsername
    public_key = tls_private_key.vre-ssh-key.public_key_openssh
  }

  source_image_id = data.azurerm_shared_image_version.packer-shared-image.id

  os_disk {
    name                 = "${random_pet.vre-identifier.id}-vm-osdisk"
    caching              = "ReadWrite"
    storage_account_type = lookup(var.diskSkuMapping, var.osdiskSku)
    disk_size_gb         = var.osdiskSize
  }

  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.vre-workspace-sa.primary_blob_endpoint
  }

  lifecycle {
    ignore_changes = [
      source_image_id # Ignore changes to the Packer image for now. If we run it now it will try to recreate the VRE when a new image is published. If we move to immutable VRE's this should be removed.
    ]
  }
}
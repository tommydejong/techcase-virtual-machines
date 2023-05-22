data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "vre-workspace-rg" {
  name = var.workspaceRG
}

data "azurerm_storage_account" "vre-workspace-sa" {
  name                = var.storageAccountName
  resource_group_name = var.workspaceRG
}

data "azurerm_shared_image_version" "packer-shared-image" {
  name                = "latest"
  gallery_name        = "packersig"
  image_name          = local.sharedImageName
  resource_group_name = "packer-images-prod"
}

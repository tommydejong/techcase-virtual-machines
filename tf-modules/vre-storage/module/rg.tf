# Resource group
resource "azurerm_resource_group" "vre-workspace-rg" {
  name     = "${var.workspaceName}-rg"
  location = var.region
  tags     = var.tags
}
# New infrastructure

# Create virtual network
resource "azurerm_virtual_network" "vre-vnet" {
  name                = "${random_pet.vre-identifier.id}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  resource_group_name = data.azurerm_resource_group.vre-workspace-rg.name
  tags                = var.tags
}

# Create subnet
resource "azurerm_subnet" "vre-subnet" {
  name                 = "${random_pet.vre-identifier.id}-subnet"
  resource_group_name  = data.azurerm_resource_group.vre-workspace-rg.name
  virtual_network_name = azurerm_virtual_network.vre-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

# Create public IPs
resource "azurerm_public_ip" "vre-pip" {
  name                = "${random_pet.vre-identifier.id}-pip"
  location            = var.region
  resource_group_name = data.azurerm_resource_group.vre-workspace-rg.name
  domain_name_label   = var.customDomainName == "" ? "${var.projectName}-vre" : var.customDomainName
  tags                = var.tags

  #public_ip_prefix_id = local.requires_trusted_ip ? data.azurerm_public_ip_prefix.trusted_public_ip_prefix.id : null
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create network interface
resource "azurerm_network_interface" "vre-nic" {
  name                = "${random_pet.vre-identifier.id}-nic"
  location            = var.region
  resource_group_name = data.azurerm_resource_group.vre-workspace-rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "${random_pet.vre-identifier.id}-nic-cfg"
    subnet_id                     = azurerm_subnet.vre-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vre-pip.id
  }
}

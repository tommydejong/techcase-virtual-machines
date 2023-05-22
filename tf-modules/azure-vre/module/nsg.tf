# Create Network Security Group and rule
resource "azurerm_network_security_group" "vre-nsg" {
  name                = "${random_pet.vre-identifier.id}-nsg"
  location            = var.region
  resource_group_name = data.azurerm_resource_group.vre-workspace-rg.name
  tags                = var.tags
}

# SSH access for GitLab runner
resource "azurerm_network_security_rule" "gitlab-runner-ssh" {
  name                        = "Allow-SSH-GitLab-Runner"
  priority                    = 3000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "20.67.108.114" # Fixed IP address
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.vre-workspace-rg.name
  network_security_group_name = azurerm_network_security_group.vre-nsg.name
}

# Access rules
# Remote access IP addresses
resource "azurerm_network_security_rule" "vre-remote_access_rule" {
  count                       = length(var.remoteAccessRules)
  name                        = "Allow-${lookup(var.remoteAccessRules[count.index], "name")}"
  priority                    = 100 + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.osType == "windows" ? "3389" : "22"
  source_address_prefix       = lookup(var.remoteAccessRules[count.index], "ip_address")
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.vre-workspace-rg.name
  network_security_group_name = azurerm_network_security_group.vre-nsg.name
}

# Allow UvA VPN
resource "azurerm_network_security_rule" "vre-allow_uva_vpn" {
  count                       = var.allowUvaVPN ? 1 : 0
  name                        = "Allow-UvA_VPN"
  priority                    = 800
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.osType == "windows" ? "3389" : "22"
  source_address_prefixes     = ["145.109.0.0/17", "145.18.0.0/16", "146.50.0.0/16"]
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.vre-workspace-rg.name
  network_security_group_name = azurerm_network_security_group.vre-nsg.name
}

# Allow HvA VPN
resource "azurerm_network_security_rule" "vre-allow_hva_vpn" {
  count                       = var.allowHvaVPN ? 1 : 0
  name                        = "Allow-HvA_VPN"
  priority                    = 810
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.osType == "windows" ? "3389" : "22"
  source_address_prefixes     = ["145.109.128.0/17", "145.92.0.0/16", "145.28.0.0/16"]
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.vre-workspace-rg.name
  network_security_group_name = azurerm_network_security_group.vre-nsg.name
}

# Allow eduVPN
resource "azurerm_network_security_rule" "vre-allow_edu_vpn" {
  count                       = var.allowEduVPN ? 1 : 0
  name                        = "Allow-eduVPN"
  priority                    = 820
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.osType == "windows" ? "3389" : "22"
  source_address_prefix       = "145.100.179.62"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.vre-workspace-rg.name
  network_security_group_name = azurerm_network_security_group.vre-nsg.name
}

# Custom additional firewall rules
resource "azurerm_network_security_rule" "vre-firewall_rule" {
  count                       = length(var.firewallRules)
  name                        = "${lookup(var.firewallRules[count.index], "access")}-${lookup(var.firewallRules[count.index], "name")}"
  priority                    = 2000 + count.index
  direction                   = lookup(var.firewallRules[count.index], "direction", "Inbound")
  access                      = lookup(var.firewallRules[count.index], "access", "Deny")
  protocol                    = lookup(var.firewallRules[count.index], "protocol", "Tcp")
  source_port_range           = lookup(var.firewallRules[count.index], "source_port_range", "*")
  destination_port_range      = lookup(var.firewallRules[count.index], "destination_port_range", "*")
  source_address_prefixes     = lookup(var.firewallRules[count.index], "source_addresses", ["*"])
  destination_address_prefix  = lookup(var.firewallRules[count.index], "destination_address", "*")
  resource_group_name         = data.azurerm_resource_group.vre-workspace-rg.name
  network_security_group_name = azurerm_network_security_group.vre-nsg.name
}

# Connect the security group to the subnet
resource "azurerm_subnet_network_security_group_association" "vre-nsg_to_subnet" {
  subnet_id                 = azurerm_subnet.vre-subnet.id
  network_security_group_id = azurerm_network_security_group.vre-nsg.id
}

# Hack to give access to workspace storage account from the created VRE subnet
resource "null_resource" "vre-subnet-access-to-sa" {
  provisioner "local-exec" {
    command = "az storage account network-rule add -g ${data.azurerm_resource_group.vre-workspace-rg.name} --account-name ${data.azurerm_storage_account.vre-workspace-sa.name} --vnet-name ${azurerm_virtual_network.vre-vnet.name} --subnet ${azurerm_subnet.vre-subnet.name} --output none"
  }
}

# Hack to give access to workspace storage account from the provided IP adresses
resource "null_resource" "ip-address-access-to-sa" {
  count = length(var.remoteAccessRules)
  provisioner "local-exec" {
    command = "az storage account network-rule add -g ${data.azurerm_resource_group.vre-workspace-rg.name} --account-name ${data.azurerm_storage_account.vre-workspace-sa.name} --ip-address ${lookup(var.remoteAccessRules[count.index], "ip_address")} --output none"
  }
}

# Storage account access -- This does not work with existing storage accounts right now. So we use local-exec with the azure cli
# resource "azurerm_storage_account_network_rules" "vre-subnet-access-to-sa" {
#   storage_account_id = data.azurerm_storage_account.vre-workspace-sa.id

#   default_action             = "Deny"
#   bypass                     = ["AzureServices", "Logging", "Metrics"]
#   # ip_rules                   = [var.remoteAccessRules]
#   virtual_network_subnet_ids = [azurerm_subnet.vre-subnet.id]
# }

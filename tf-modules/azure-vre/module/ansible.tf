# Ansible configuration
resource "ansible_host" "vre-ansible" {
  inventory_hostname = azurerm_public_ip.vre-pip.fqdn
  groups = flatten([
    var.osType, (var.azFileStorage ? "az_files" : "no_az_files"), (var.researchdrive ? "rdrive" : "no_rdrive"),
    (var.jcApiKey != "" ? "jumpcloud" : "no_jumpcloud"),
    local.software_list
  ])
  vars = {
    ansible_user       = local.adminUsername
    ansible_connection = "ssh"
    ansible_shell_type = local.shell_type
    vre_kv             = azurerm_key_vault.vre-kv.name
    vre_workspace_rg   = data.azurerm_resource_group.vre-workspace-rg.name
    vre_workspace_sa   = data.azurerm_storage_account.vre-workspace-sa.name
    vre_subscription   = data.azurerm_client_config.current.subscription_id
    vre_instance       = lookup(var.tags, "instance")
  }
}

output "vre_private_ssh_key" {
  description = "The private SSH key to access the VRE"
  sensitive   = true
  value       = tls_private_key.vre-ssh-key.private_key_pem
}

output "key_vault_name" {
  description = "The name of the created key vault"
  value       = azurerm_key_vault.vre-kv.name
}
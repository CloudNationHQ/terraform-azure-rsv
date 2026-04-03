output "vault" {
  description = "Contains all recovery services vault configuration"
  value       = azurerm_recovery_services_vault.vault
}

output "policies_file_share" {
  description = "Contains all file share backup policy configuration"
  value       = azurerm_backup_policy_file_share.policy
}

output "policies_vm" {
  description = "Contains all vm backup policy configuration"
  value       = azurerm_backup_policy_vm.policy
}

output "policies_vm_workload" {
  description = "Contains all vm workload backup policy configuration"
  value       = azurerm_backup_policy_vm_workload.policy
}

output "protected_vms" {
  description = "Contains all backup protected vm configuration"
  value       = azurerm_backup_protected_vm.vm
}

output "protected_file_shares" {
  description = "Contains all backup protected file share configuration"
  value       = azurerm_backup_protected_file_share.share
}

output "container_storage_accounts" {
  description = "Contains all backup container storage account configuration"
  value       = azurerm_backup_container_storage_account.container
}

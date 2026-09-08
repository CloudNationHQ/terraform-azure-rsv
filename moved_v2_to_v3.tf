moved {
  from = azurerm_recovery_services_vault.vault
  to   = azurerm_recovery_services_vault.this
}

moved {
  from = azurerm_backup_policy_file_share.policy
  to   = azurerm_backup_policy_file_share.this
}

moved {
  from = azurerm_backup_policy_vm.policy
  to   = azurerm_backup_policy_vm.this
}

moved {
  from = azurerm_backup_policy_vm_workload.policy
  to   = azurerm_backup_policy_vm_workload.this
}

moved {
  from = azurerm_backup_protected_vm.vm
  to   = azurerm_backup_protected_vm.this
}

moved {
  from = azurerm_backup_container_storage_account.container
  to   = azurerm_backup_container_storage_account.this
}

moved {
  from = azurerm_backup_protected_file_share.share
  to   = azurerm_backup_protected_file_share.this
}

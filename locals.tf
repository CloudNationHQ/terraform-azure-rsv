locals {
  protected_vms_map = merge([
    for policy_name, policy in lookup(var.vault, "policies", {}) != {} ? lookup(var.vault.policies, "vms", {}) : {} : {
      for vm_name, vm_details in lookup(policy, "protected_vms", {}) : "${policy_name}-${vm_name}" => {
        resource_group_name = var.vault.resourcegroup,
        recovery_vault_name = var.vault.name,
        source_vm_id        = vm_details.id,
        name                = try(policy_name, var.naming.recovery_services_vault_backup_policy)
      }
    }
  ]...)

  protected_file_share_map = merge([
    for policy_name, policy in lookup(var.vault, "policies", {}) != {} ? lookup(var.vault.policies, "file_shares", {}) : {} : {
      for file_share_name, file_share_details in lookup(policy, "protected_file_shares", {}) : "${policy_name}-${file_share_name}" => {
        resource_group_name       = var.vault.resourcegroup,
        recovery_vault_name       = var.vault.name,
        source_storage_account_id = file_share_details.id,
        source_file_share_name    = file_share_name,
        backup_policy_id          = try(policy.backup_policy_id, azurerm_backup_policy_file_share.policy[policy_name].id),
      }
    }
  ]...)
}

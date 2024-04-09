locals {
  protected_vms_map = merge([
    for policy_name, policy in lookup(var.vault, "policies", {}) != {} ? lookup(var.vault.policies, "vms", {}) : {} : {
      for vm_name, vm_details in lookup(policy, "protected_vms", {}) : "${policy_name}-${vm_name}" => {
        resource_group_name = var.vault.resourcegroup
        recovery_vault_name = var.vault.name,
        source_vm_id        = vm_details.id,
        name                = try(policy_name, var.naming.recovery_services_vault_backup_policy)
      }
    }
  ]...)
}

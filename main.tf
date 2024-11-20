# recovery vault
resource "azurerm_recovery_services_vault" "vault" {
  name                               = var.vault.name
  resource_group_name                = coalesce(lookup(var.vault, "resource_group", null), var.resource_group)
  location                           = coalesce(lookup(var.vault, "location", null), var.location)
  sku                                = try(var.vault.sku, "Standard")
  soft_delete_enabled                = try(var.vault.soft_delete_enabled, false)
  immutability                       = try(var.vault.immutability, "Disabled")
  cross_region_restore_enabled       = try(var.vault.cross_region_restore_enabled, null)
  storage_mode_type                  = try(var.vault.storage_mode_type, "GeoRedundant")
  public_network_access_enabled      = try(var.vault.public_network_access_enabled, true)
  classic_vmware_replication_enabled = try(var.vault.classic_vmware_replication_enabled, null)
  tags                               = try(var.vault.tags, var.tags, null)
}

# policies file share
resource "azurerm_backup_policy_file_share" "policy" {
  for_each = lookup(
    lookup(var.vault, "policies", {}), "file_shares", {}
  )

  name                = try(each.value.name, join("-", [var.naming.recovery_services_vault_backup_policy, each.key]))
  resource_group_name = coalesce(try(var.vault.resource_group, null), var.resource_group)
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  timezone            = try(each.value.timezone, "UTC")

  backup {
    frequency = each.value.backup.frequency
    time      = each.value.backup.time
  }

  retention_daily {
    count = each.value.retention.daily.count
  }

  dynamic "retention_weekly" {
    for_each = try(
      each.value.retention.weekly != null ? [each.value.retention.weekly] : [], []
    )

    content {
      count    = try(retention_weekly.value.count, null)
      weekdays = try(retention_weekly.value.weekdays, [])
    }
  }

  dynamic "retention_monthly" {
    for_each = try(
      each.value.retention.monthly != null ? [each.value.retention.monthly] : [], []
    )

    content {
      count    = try(retention_monthly.value.count, null)
      weekdays = try(retention_monthly.value.weekdays, [])
      weeks    = try(retention_monthly.value.weeks, [])
    }
  }

  dynamic "retention_yearly" {
    for_each = try(
      each.value.retention.yearly != null ? [each.value.retention.yearly] : [], []
    )

    content {
      count    = try(retention_yearly.value.count, null)
      weekdays = try(retention_yearly.value.weekdays, [])
      weeks    = try(retention_yearly.value.weeks, [])
      months   = try(retention_yearly.value.months, [])
    }
  }
}

# policies vm
resource "azurerm_backup_policy_vm" "policy" {
  for_each = lookup(
    lookup(var.vault, "policies", {}), "vms", {}
  )

  name                = try(each.value.name, join("-", [var.naming.recovery_services_vault_backup_policy, each.key]))
  resource_group_name = coalesce(try(var.vault.resource_group, null), var.resource_group)
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  timezone            = try(each.value.timezone, "UTC")
  policy_type         = try(each.value.policy_type, "V1")

  backup {
    frequency = each.value.backup.frequency
    time      = each.value.backup.time
  }

  dynamic "retention_daily" {
    for_each = try(
      each.value.retention.daily != null ? [each.value.retention.daily] : [], []
    )

    content {
      count = try(retention_daily.value.count, null)
    }
  }

  dynamic "retention_weekly" {
    for_each = try(
      each.value.retention.weekly != null ? [each.value.retention.weekly] : [], []
    )

    content {
      count    = try(retention_weekly.value.count, null)
      weekdays = try(retention_weekly.value.weekdays, [])
    }
  }

  dynamic "retention_yearly" {
    for_each = try(
      each.value.retention.yearly != null ? [each.value.retention.yearly] : [], []
    )

    content {
      count    = try(retention_yearly.value.count, null)
      weekdays = try(retention_yearly.value.weekdays, [])
      weeks    = try(retention_yearly.value.weeks, [])
      months   = try(retention_yearly.value.months, [])
    }
  }
}

resource "azurerm_backup_protected_vm" "vm" {
  for_each = merge([
    for policy_name, policy in lookup(var.vault, "policies", {}) != {} ? lookup(var.vault.policies, "vms", {}) : {} : {
      for vm_name, vm_details in lookup(policy, "protected_vms", {}) : "${policy_name}-${vm_name}" => {
        recovery_vault_name = azurerm_recovery_services_vault.vault.name
        source_vm_id        = vm_details.id
        policy_name         = policy_name
        resource_group_name = coalesce(
          try(var.vault.resource_group, null), var.resource_group
        )
      }
    }
  ]...)

  resource_group_name = each.value.resource_group_name
  recovery_vault_name = each.value.recovery_vault_name
  source_vm_id        = each.value.source_vm_id
  backup_policy_id    = azurerm_backup_policy_vm.policy[each.value.policy_name].id
}

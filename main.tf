# recovery vault
resource "azurerm_recovery_services_vault" "vault" {
  name                               = var.vault.name
  resource_group_name                = coalesce(lookup(var.vault, "resourcegroup", null), var.resourcegroup)
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
  resource_group_name = coalesce(try(var.vault.resourcegroup, null), var.resourcegroup)
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
  resource_group_name = coalesce(try(var.vault.resourcegroup, null), var.resourcegroup)
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
  for_each = local.protected_vms_map

  resource_group_name = each.value.resource_group_name
  recovery_vault_name = each.value.recovery_vault_name
  source_vm_id        = each.value.source_vm_id
  backup_policy_id    = azurerm_backup_policy_vm.policy[each.value.policy_name].id
}

# Container Backup Container
resource "azurerm_backup_container_storage_account" "container" {
  # for_each = local.protected_file_share_map

  resource_group_name = coalesce(lookup(var.vault, "resourcegroup", null), var.resourcegroup)
  recovery_vault_name = var.vault.name
  storage_account_id  = var.storage_account_id
}

# FileShare Backup
resource "azurerm_backup_protected_file_share" "file_share" {
  for_each = local.protected_file_share_map

  resource_group_name       = each.value.resource_group_name
  recovery_vault_name       = each.value.recovery_vault_name
  source_storage_account_id = each.value.source_storage_account_id
  source_file_share_name    = each.value.source_file_share_name
  backup_policy_id          = each.value.backup_policy_id
}

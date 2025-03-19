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

  dynamic "identity" {
    for_each = try(lookup(var.vault, "identity", null) != null ? [var.vault.identity] : [])
    content {
      type         = var.vault.identity.type
      identity_ids = try(var.vault.identity.identity_ids, [])
    }

  }

  dynamic "encryption" {
    for_each = try(lookup(var.vault, "encryption", null) != null ? [var.vault.encryption] : [])
    content {
      key_id                            = var.vault.encryption.key_id
      infrastructure_encryption_enabled = var.vault.encryption.infrastructure_encryption_enabled
      user_assigned_identity_id         = try(var.vault.encryption.user_assigned_identity_id, null)
      use_system_assigned_identity      = try(var.vault.encryption.use_system_assigned_identity, true)
    }
  }

  dynamic "monitoring" {
    for_each = try(lookup(var.vault, "monitoring", null) != null ? [var.vault.monitoring] : [])
    content {
      alerts_for_all_job_failures_enabled            = try(var.vault.monitoring.alerts_for_all_job_failures_enabled, true)
      alerts_for_critical_operation_failures_enabled = try(var.vault.monitoring.alerts_for_critical_operation_failures_enabled, true)
    }

  }
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
    time      = try(each.value.backup.time, null)

    dynamic "hourly" {
      for_each = try(
        each.value.backup.hourly != null ? [each.value.backup.hourly] : [], []
      )

      content {
        interval        = each.value.backup.hourly.interval
        start_time      = each.value.backup.hourly.start_time
        window_duration = each.value.backup.hourly.window_duration
      }
    }
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
      count             = try(retention_monthly.value.count, null)
      weekdays          = try(retention_monthly.value.weekdays, [])
      weeks             = try(retention_monthly.value.weeks, [])
      days              = try(retention_monthly.value.days, [])
      include_last_days = try(retention_monthly.value.include_last_days, false)
    }
  }

  dynamic "retention_yearly" {
    for_each = try(
      each.value.retention.yearly != null ? [each.value.retention.yearly] : [], []
    )

    content {
      count             = try(retention_yearly.value.count, null)
      weekdays          = try(retention_yearly.value.weekdays, [])
      weeks             = try(retention_yearly.value.weeks, [])
      months            = try(retention_yearly.value.months, [])
      days              = try(retention_yearly.value.days, [])
      include_last_days = try(retention_yearly.value.include_last_days, false)
    }
  }
}

# policies vm
resource "azurerm_backup_policy_vm" "policy" {
  for_each = lookup(
    lookup(var.vault, "policies", {}), "vms", {}
  )

  name                           = try(each.value.name, join("-", [var.naming.recovery_services_vault_backup_policy, each.key]))
  resource_group_name            = coalesce(try(var.vault.resource_group, null), var.resource_group)
  recovery_vault_name            = azurerm_recovery_services_vault.vault.name
  timezone                       = try(each.value.timezone, "UTC")
  policy_type                    = try(each.value.policy_type, "V1")
  instant_restore_retention_days = try(each.value.instant_restore_retention_days, null)

  dynamic "instant_restore_resource_group" {
    for_each = try(
      each.value.instant_restore_resource_group != null ? [each.value.instant_restore_resource_group] : [], []
    )

    content {
      prefix = instant_restore_resource_group.value.prefix
      suffix = try(instant_restore_resource_group.value.suffix, null)
    }

  }

  dynamic "tiering_policy" {
    for_each = try(
      each.value.tiering_policy != null ? [each.value.tiering_policy] : [], []
    )

    content {
      dynamic "archived_restore_point" {
        for_each = try(
          tiering_policy.value.archived_restore_point != null ? [tiering_policy.value.archived_restore_point] : [], []
        )

        content {
          mode          = archived_restore_point.value.mode
          duration      = try(archived_restore_point.value.duration, null)
          duration_type = try(archived_restore_point.value.duration_type, null)
        }
      }
    }
  }

  backup {
    frequency     = each.value.backup.frequency
    time          = each.value.backup.time
    hour_interval = try(each.value.backup.hour_interval, null)
    hour_duration = try(each.value.backup.hour_duration, null)
    weekdays      = try(each.value.backup.weekdays, null)
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
      weekdays = try(retention_weekly.value.weekdays, null)
    }
  }

  dynamic "retention_monthly" {
    for_each = try(
      each.value.retention.monthly != null ? [each.value.retention.monthly] : [], []
    )

    content {
      count             = try(retention_monthly.value.count, null)
      weekdays          = try(retention_monthly.value.weekdays, [])
      weeks             = try(retention_monthly.value.weeks, [])
      days              = try(retention_monthly.value.days, [])
      include_last_days = try(retention_monthly.value.include_last_days, false)
    }
  }

  dynamic "retention_yearly" {
    for_each = try(
      each.value.retention.yearly != null ? [each.value.retention.yearly] : [], []
    )

    content {
      count             = try(retention_yearly.value.count, null)
      weekdays          = try(retention_yearly.value.weekdays, [])
      weeks             = try(retention_yearly.value.weeks, [])
      months            = try(retention_yearly.value.months, [])
      days              = try(retention_yearly.value.days, [])
      include_last_days = try(retention_yearly.value.include_last_days, false)
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
        include_disk_luns   = try(vm_details.include_disk_luns, null)
        exclude_disk_luns   = try(vm_details.exclude_disk_luns, null)
        protection_state    = try(vm_details.protection_state, null)
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
  exclude_disk_luns   = each.value.exclude_disk_luns
  include_disk_luns   = each.value.include_disk_luns
  protection_state    = each.value.protection_state
}

# register the storage account as a backup container
resource "azurerm_backup_container_storage_account" "container" {
  for_each = {
    for policy_name, policy in lookup(var.vault, "policies", {}) != {} ? lookup(var.vault.policies, "file_shares", {}) : {} :
    policy_name => {
      storage_account_id  = lookup(policy, "protected_shares", null) != null ? values(policy.protected_shares)[0].storage_account_id : null
      recovery_vault_name = azurerm_recovery_services_vault.vault.name
      resource_group_name = coalesce(try(var.vault.resource_group, null), var.resource_group)
    }
    if lookup(policy, "protected_shares", null) != null
  }

  storage_account_id  = each.value.storage_account_id
  recovery_vault_name = each.value.recovery_vault_name
  resource_group_name = each.value.resource_group_name
}

# file share protection
resource "azurerm_backup_protected_file_share" "share" {
  for_each = merge([
    for policy_name, policy in lookup(var.vault, "policies", {}) != {} ? lookup(var.vault.policies, "file_shares", {}) : {} : {
      for share_name, share_details in lookup(policy, "protected_shares", {}) : "${policy_name}-${share_name}" => {
        recovery_vault_name       = azurerm_recovery_services_vault.vault.name
        source_storage_account_id = share_details.storage_account_id
        source_file_share_name    = share_details.name
        policy_name               = policy_name
        resource_group_name = coalesce(
          try(var.vault.resource_group, null), var.resource_group
        )
      }
    }
  ]...)

  resource_group_name       = each.value.resource_group_name
  recovery_vault_name       = each.value.recovery_vault_name
  source_storage_account_id = each.value.source_storage_account_id
  source_file_share_name    = each.value.source_file_share_name
  backup_policy_id          = azurerm_backup_policy_file_share.policy[each.value.policy_name].id

  depends_on = [azurerm_backup_container_storage_account.container]
}

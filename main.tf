# recovery vault
resource "azurerm_recovery_services_vault" "vault" {
  resource_group_name = coalesce(
    lookup(
      var.vault, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.vault, "location", null
    ), var.location
  )

  name                               = var.vault.name
  sku                                = var.vault.sku
  soft_delete_enabled                = var.vault.soft_delete_enabled
  immutability                       = var.vault.immutability
  cross_region_restore_enabled       = var.vault.cross_region_restore_enabled
  storage_mode_type                  = var.vault.storage_mode_type
  public_network_access_enabled      = var.vault.public_network_access_enabled
  classic_vmware_replication_enabled = var.vault.classic_vmware_replication_enabled

  tags = coalesce(
    var.vault.tags, var.tags
  )

  dynamic "identity" {
    for_each = try(lookup(var.vault, "identity", null) != null ? [var.vault.identity] : [])
    content {
      type         = var.vault.identity.type
      identity_ids = var.vault.identity.identity_ids
    }
  }

  dynamic "encryption" {
    for_each = try(lookup(var.vault, "encryption", null) != null ? [var.vault.encryption] : [])

    content {
      key_id                            = var.vault.encryption.key_id
      infrastructure_encryption_enabled = var.vault.encryption.infrastructure_encryption_enabled
      user_assigned_identity_id         = var.vault.encryption.user_assigned_identity_id
      use_system_assigned_identity      = var.vault.encryption.use_system_assigned_identity
    }
  }

  dynamic "monitoring" {
    for_each = try(lookup(var.vault, "monitoring", null) != null ? [var.vault.monitoring] : [])

    content {
      alerts_for_all_job_failures_enabled            = var.vault.monitoring.alerts_for_all_job_failures_enabled
      alerts_for_critical_operation_failures_enabled = var.vault.monitoring.alerts_for_critical_operation_failures_enabled
    }

  }
}

# policies file share
resource "azurerm_backup_policy_file_share" "policy" {
  for_each = lookup(
    lookup(var.vault, "policies", {}), "file_shares", {}
  )

  name = coalesce(
    each.value.name, join("-", [var.naming.recovery_services_vault_backup_policy, each.key])
  )

  resource_group_name = coalesce(
    lookup(
      var.vault, "resource_group_name", null
    ), var.resource_group_name
  )


  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  timezone            = each.value.timezone

  backup {
    frequency = each.value.backup.frequency
    time      = each.value.backup.time

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
      count    = retention_weekly.value.count
      weekdays = retention_weekly.value.weekdays
    }
  }

  dynamic "retention_monthly" {
    for_each = try(
      each.value.retention.monthly != null ? [each.value.retention.monthly] : [], []
    )

    content {
      count             = retention_monthly.value.count
      weekdays          = retention_monthly.value.weekdays
      weeks             = retention_monthly.value.weeks
      days              = retention_monthly.value.days
      include_last_days = retention_monthly.value.include_last_days
    }
  }

  dynamic "retention_yearly" {
    for_each = try(
      each.value.retention.yearly != null ? [each.value.retention.yearly] : [], []
    )

    content {
      count             = retention_yearly.value.count
      weekdays          = retention_yearly.value.weekdays
      weeks             = retention_yearly.value.weeks
      months            = retention_yearly.value.months
      days              = retention_yearly.value.days
      include_last_days = retention_yearly.value.include_last_days
    }
  }
}

# policies vm
resource "azurerm_backup_policy_vm" "policy" {
  for_each = lookup(
    lookup(var.vault, "policies", {}), "vms", {}
  )

  name = coalesce(
    each.value.name, join("-", [var.naming.recovery_services_vault_backup_policy, each.key])
  )

  resource_group_name = coalesce(
    lookup(
      var.vault, "resource_group_name", null
    ), var.resource_group_name
  )

  recovery_vault_name            = azurerm_recovery_services_vault.vault.name
  timezone                       = each.value.timezone
  policy_type                    = each.value.policy_type
  instant_restore_retention_days = each.value.instant_restore_retention_days

  dynamic "instant_restore_resource_group" {
    for_each = try(
      each.value.instant_restore_resource_group != null ? [each.value.instant_restore_resource_group] : [], []
    )

    content {
      prefix = instant_restore_resource_group.value.prefix
      suffix = instant_restore_resource_group.value.suffix
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
          duration      = archived_restore_point.value.duration
          duration_type = archived_restore_point.value.duration_type
        }
      }
    }
  }

  backup {
    frequency     = each.value.backup.frequency
    time          = each.value.backup.time
    hour_interval = each.value.backup.hour_interval
    hour_duration = each.value.backup.hour_duration
    weekdays      = each.value.backup.weekdays
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
      count    = retention_weekly.value.count
      weekdays = retention_weekly.value.weekdays
    }
  }

  dynamic "retention_monthly" {
    for_each = try(
      each.value.retention.monthly != null ? [each.value.retention.monthly] : [], []
    )

    content {
      count             = retention_monthly.value.count
      weekdays          = retention_monthly.value.weekdays
      weeks             = retention_monthly.value.weeks
      days              = retention_monthly.value.days
      include_last_days = retention_monthly.value.include_last_days
    }
  }

  dynamic "retention_yearly" {
    for_each = try(
      each.value.retention.yearly != null ? [each.value.retention.yearly] : [], []
    )

    content {
      count             = retention_yearly.value.count
      weekdays          = retention_yearly.value.weekdays
      weeks             = retention_yearly.value.weeks
      months            = retention_yearly.value.months
      days              = retention_yearly.value.days
      include_last_days = retention_yearly.value.include_last_days
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
        include_disk_luns   = vm_details.include_disk_luns
        exclude_disk_luns   = vm_details.exclude_disk_luns
        protection_state    = vm_details.protection_state
        resource_group_name = coalesce(
          lookup(
            var.vault, "resource_group_name", null
          ), var.resource_group_name
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
      storage_account_id  = lookup(policy, "protected_shares", null) != null && length(values(policy.protected_shares)) > 0 ? values(policy.protected_shares)[0].storage_account_id : null
      recovery_vault_name = azurerm_recovery_services_vault.vault.name
      resource_group_name = coalesce(
        lookup(
          var.vault, "resource_group_name", null
        ), var.resource_group_name
      )
    }
    if lookup(policy, "protected_shares", null) != null && length(values(lookup(policy, "protected_shares", {}))) > 0
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
          lookup(
            var.vault, "resource_group_name", null
          ), var.resource_group_name
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

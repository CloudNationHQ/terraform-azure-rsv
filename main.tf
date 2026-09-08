# recovery vault
resource "azurerm_recovery_services_vault" "this" {
  resource_group_name = coalesce(
    var.vault.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.vault.location, var.location
  )

  name                               = var.vault.name
  sku                                = var.vault.sku
  immutability                       = var.vault.immutability
  cross_region_restore_enabled       = var.vault.cross_region_restore_enabled
  storage_mode_type                  = var.vault.storage_mode_type
  public_network_access_enabled      = var.vault.public_network_access_enabled
  classic_vmware_replication_enabled = var.vault.classic_vmware_replication_enabled

  tags = coalesce(
    var.vault.tags, var.tags
  )

  dynamic "identity" {
    for_each = var.vault.identity != null ? { "this" = var.vault.identity } : {}

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "encryption" {
    for_each = var.vault.encryption != null ? { "this" = var.vault.encryption } : {}

    content {
      key_id                            = encryption.value.key_id
      infrastructure_encryption_enabled = encryption.value.infrastructure_encryption_enabled
      user_assigned_identity_id         = encryption.value.user_assigned_identity_id
      use_system_assigned_identity      = encryption.value.use_system_assigned_identity
    }
  }

  dynamic "monitoring" {
    for_each = var.vault.monitoring != null ? { "this" = var.vault.monitoring } : {}

    content {
      alerts_for_all_job_failures_enabled            = monitoring.value.alerts_for_all_job_failures_enabled
      alerts_for_critical_operation_failures_enabled = monitoring.value.alerts_for_critical_operation_failures_enabled
      alerts_for_all_failover_issues_enabled         = monitoring.value.alerts_for_all_failover_issues_enabled
      alerts_for_all_replication_issues_enabled      = monitoring.value.alerts_for_all_replication_issues_enabled
      email_notifications_for_site_recovery_enabled  = monitoring.value.email_notifications_for_site_recovery_enabled
    }
  }
}

# policies file share
resource "azurerm_backup_policy_file_share" "this" {
  for_each = var.vault.policies.file_shares

  name = coalesce(
    each.value.name, each.key
  )

  resource_group_name = coalesce(
    var.vault.resource_group_name, var.resource_group_name
  )

  recovery_vault_name = azurerm_recovery_services_vault.this.name
  timezone            = each.value.timezone

  backup_tier                = each.value.backup_tier
  snapshot_retention_in_days = each.value.snapshot_retention_in_days

  backup {
    frequency = each.value.backup.frequency
    time      = each.value.backup.time

    dynamic "hourly" {
      for_each = each.value.backup.hourly != null ? { "this" = each.value.backup.hourly } : {}

      content {
        interval        = hourly.value.interval
        start_time      = hourly.value.start_time
        window_duration = hourly.value.window_duration
      }
    }
  }

  retention_daily {
    count = each.value.retention.daily.count
  }

  dynamic "retention_weekly" {
    for_each = each.value.retention.weekly != null ? { "this" = each.value.retention.weekly } : {}

    content {
      count    = retention_weekly.value.count
      weekdays = retention_weekly.value.weekdays
    }
  }

  dynamic "retention_monthly" {
    for_each = each.value.retention.monthly != null ? { "this" = each.value.retention.monthly } : {}

    content {
      count             = retention_monthly.value.count
      weekdays          = retention_monthly.value.weekdays
      weeks             = retention_monthly.value.weeks
      days              = retention_monthly.value.days
      include_last_days = retention_monthly.value.include_last_days
    }
  }

  dynamic "retention_yearly" {
    for_each = each.value.retention.yearly != null ? { "this" = each.value.retention.yearly } : {}

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
resource "azurerm_backup_policy_vm" "this" {
  for_each = var.vault.policies.vms

  name = coalesce(
    each.value.name, each.key
  )

  resource_group_name = coalesce(
    var.vault.resource_group_name, var.resource_group_name
  )

  recovery_vault_name            = azurerm_recovery_services_vault.this.name
  timezone                       = each.value.timezone
  policy_type                    = each.value.policy_type
  consistency_type               = each.value.consistency_type
  instant_restore_retention_days = each.value.instant_restore_retention_days

  dynamic "instant_restore_resource_group" {
    for_each = each.value.instant_restore_resource_group != null ? { "this" = each.value.instant_restore_resource_group } : {}

    content {
      prefix = instant_restore_resource_group.value.prefix
      suffix = instant_restore_resource_group.value.suffix
    }
  }

  dynamic "tiering_policy" {
    for_each = each.value.tiering_policy != null ? { "this" = each.value.tiering_policy } : {}

    content {
      dynamic "archived_restore_point" {
        for_each = tiering_policy.value.archived_restore_point != null ? { "this" = tiering_policy.value.archived_restore_point } : {}

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
    for_each = each.value.retention.daily != null ? { "this" = each.value.retention.daily } : {}

    content {
      count = retention_daily.value.count
    }
  }

  dynamic "retention_weekly" {
    for_each = each.value.retention.weekly != null ? { "this" = each.value.retention.weekly } : {}

    content {
      count    = retention_weekly.value.count
      weekdays = retention_weekly.value.weekdays
    }
  }

  dynamic "retention_monthly" {
    for_each = each.value.retention.monthly != null ? { "this" = each.value.retention.monthly } : {}

    content {
      count             = retention_monthly.value.count
      weekdays          = retention_monthly.value.weekdays
      weeks             = retention_monthly.value.weeks
      days              = retention_monthly.value.days
      include_last_days = retention_monthly.value.include_last_days
    }
  }

  dynamic "retention_yearly" {
    for_each = each.value.retention.yearly != null ? { "this" = each.value.retention.yearly } : {}

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

# policies vm workload
resource "azurerm_backup_policy_vm_workload" "this" {
  for_each = var.vault.policies.vm_workloads

  name = coalesce(
    each.value.name, each.key
  )

  resource_group_name = coalesce(
    var.vault.resource_group_name, var.resource_group_name
  )

  recovery_vault_name = azurerm_recovery_services_vault.this.name
  workload_type       = each.value.workload_type

  settings {
    time_zone           = each.value.settings.time_zone
    compression_enabled = each.value.settings.compression_enabled
  }

  dynamic "protection_policy" {
    for_each = each.value.protection_policies

    content {
      policy_type = protection_policy.value.policy_type

      backup {
        frequency            = protection_policy.value.backup.frequency
        frequency_in_minutes = protection_policy.value.backup.frequency_in_minutes
        time                 = protection_policy.value.backup.time
        weekdays             = protection_policy.value.backup.weekdays
      }

      dynamic "retention_daily" {
        for_each = protection_policy.value.retention_daily != null ? { "this" = protection_policy.value.retention_daily } : {}

        content {
          count = retention_daily.value.count
        }
      }

      dynamic "retention_weekly" {
        for_each = protection_policy.value.retention_weekly != null ? { "this" = protection_policy.value.retention_weekly } : {}

        content {
          count    = retention_weekly.value.count
          weekdays = retention_weekly.value.weekdays
        }
      }

      dynamic "retention_monthly" {
        for_each = protection_policy.value.retention_monthly != null ? { "this" = protection_policy.value.retention_monthly } : {}

        content {
          count       = retention_monthly.value.count
          format_type = retention_monthly.value.format_type
          monthdays   = retention_monthly.value.monthdays
          weekdays    = retention_monthly.value.weekdays
          weeks       = retention_monthly.value.weeks
        }
      }

      dynamic "retention_yearly" {
        for_each = protection_policy.value.retention_yearly != null ? { "this" = protection_policy.value.retention_yearly } : {}

        content {
          count       = retention_yearly.value.count
          format_type = retention_yearly.value.format_type
          months      = retention_yearly.value.months
          monthdays   = retention_yearly.value.monthdays
          weekdays    = retention_yearly.value.weekdays
          weeks       = retention_yearly.value.weeks
        }
      }

      dynamic "simple_retention" {
        for_each = protection_policy.value.simple_retention != null ? { "this" = protection_policy.value.simple_retention } : {}

        content {
          count = simple_retention.value.count
        }
      }
    }
  }
}

resource "azurerm_backup_protected_vm" "this" {
  for_each = merge([
    for policy_name, policy in var.vault.policies.vms : {
      for vm_name, vm in policy.protected_vms : "${policy_name}-${vm_name}" => merge(vm, { policy_name = policy_name })
    }
  ]...)

  resource_group_name = coalesce(
    var.vault.resource_group_name, var.resource_group_name
  )

  recovery_vault_name = azurerm_recovery_services_vault.this.name
  source_vm_id        = each.value.id
  backup_policy_id    = azurerm_backup_policy_vm.this[each.value.policy_name].id
  exclude_disk_luns   = each.value.exclude_disk_luns
  include_disk_luns   = each.value.include_disk_luns
  protection_state    = each.value.protection_state
}

# register the storage account as a backup container
resource "azurerm_backup_container_storage_account" "this" {
  for_each = {
    for policy_name, policy in var.vault.policies.file_shares :
    policy_name => values(policy.protected_shares)[0].storage_account_id
    if length(policy.protected_shares) > 0
  }

  resource_group_name = coalesce(
    var.vault.resource_group_name, var.resource_group_name
  )

  storage_account_id  = each.value
  recovery_vault_name = azurerm_recovery_services_vault.this.name
}

# file share protection
resource "azurerm_backup_protected_file_share" "this" {
  for_each = merge([
    for policy_name, policy in var.vault.policies.file_shares : {
      for share_name, share in policy.protected_shares : "${policy_name}-${share_name}" => merge(share, { policy_name = policy_name })
    }
  ]...)

  resource_group_name = coalesce(
    var.vault.resource_group_name, var.resource_group_name
  )
  recovery_vault_name       = azurerm_recovery_services_vault.this.name
  source_storage_account_id = each.value.storage_account_id
  source_file_share_name    = each.value.name
  backup_policy_id          = azurerm_backup_policy_file_share.this[each.value.policy_name].id

  depends_on = [azurerm_backup_container_storage_account.this]
}

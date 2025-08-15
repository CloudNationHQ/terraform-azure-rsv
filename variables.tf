variable "vault" {
  description = "Contains all recovery services vault configuration"
  type = object({
    name                               = string
    resource_group_name                = optional(string)
    location                           = optional(string)
    sku                                = optional(string, "Standard")
    soft_delete_enabled                = optional(bool, false)
    immutability                       = optional(string, "Disabled")
    cross_region_restore_enabled       = optional(bool, false)
    storage_mode_type                  = optional(string, "GeoRedundant")
    public_network_access_enabled      = optional(bool, true)
    classic_vmware_replication_enabled = optional(bool, false)
    tags                               = optional(map(string))
    identity = optional(object({
      type         = string
      identity_ids = optional(set(string), [])
    }), null)
    encryption = optional(object({
      key_id                            = string
      infrastructure_encryption_enabled = bool
      user_assigned_identity_id         = optional(string)
      use_system_assigned_identity      = optional(bool, true)
    }), null)
    monitoring = optional(object({
      alerts_for_all_job_failures_enabled            = optional(bool, true)
      alerts_for_critical_operation_failures_enabled = optional(bool, true)
    }), null)
    policies = optional(object({
      file_shares = optional(map(object({
        name     = optional(string)
        timezone = optional(string, "UTC")
        backup = object({
          frequency = string
          time      = optional(string)
          hourly = optional(object({
            interval        = number
            start_time      = string
            window_duration = number
          }), null)
        })
        retention = object({
          daily = object({
            count = number
          })
          weekly = optional(object({
            count    = optional(number)
            weekdays = optional(set(string), [])
          }), null)
          monthly = optional(object({
            count             = optional(number)
            weekdays          = optional(set(string))
            weeks             = optional(set(string))
            days              = optional(set(number))
            include_last_days = optional(bool, false)
          }), null)
          yearly = optional(object({
            count             = optional(number)
            weekdays          = optional(set(string), [])
            weeks             = optional(set(string), [])
            months            = optional(set(string), [])
            days              = optional(set(number))
            include_last_days = optional(bool, false)
          }), null)
        })
        protected_shares = optional(map(object({
          name               = string
          storage_account_id = string
        })), {})
      })), {})
      vms = optional(map(object({
        name                           = optional(string)
        timezone                       = optional(string, "UTC")
        policy_type                    = optional(string, "V1")
        instant_restore_retention_days = optional(number)
        instant_restore_resource_group = optional(object({
          prefix = string
          suffix = optional(string)
        }), null)
        tiering_policy = optional(object({
          archived_restore_point = optional(object({
            mode          = string
            duration      = optional(number)
            duration_type = optional(string)
          }), null)
        }), null)
        backup = object({
          frequency     = string
          time          = string
          hour_interval = optional(number)
          hour_duration = optional(number)
          weekdays      = optional(set(string))
        })
        retention = object({
          daily = optional(object({
            count = optional(number)
          }), null)
          weekly = optional(object({
            count    = optional(number)
            weekdays = optional(set(string))
          }), null)
          monthly = optional(object({
            count             = optional(number)
            weekdays          = optional(set(string), [])
            weeks             = optional(set(string), [])
            days              = optional(list(number), [])
            include_last_days = optional(bool, false)
          }), null)
          yearly = optional(object({
            count             = optional(number)
            weekdays          = optional(set(string), [])
            weeks             = optional(set(string), [])
            months            = optional(set(string), [])
            days              = optional(list(number), [])
            include_last_days = optional(bool, false)
          }), null)
        })
        protected_vms = optional(map(object({
          id                = string
          include_disk_luns = optional(list(number))
          exclude_disk_luns = optional(list(number))
          protection_state  = optional(string)
        })), {})
      })), {})
    }), {})
  })
  validation {
    condition     = var.vault.location != null || var.location != null
    error_message = "location must be provided either in the config object or as a separate variable."
  }

  validation {
    condition     = var.vault.resource_group_name != null || var.resource_group_name != null
    error_message = "resource group name must be provided either in the config object or as a separate variable."
  }

  validation {
    condition = var.vault.encryption == null || (
      var.vault.encryption != null && (
        var.vault.encryption.use_system_assigned_identity == true ||
        var.vault.encryption.user_assigned_identity_id != null
      )
    )
    error_message = "When encryption is enabled, either use_system_assigned_identity must be true or user_assigned_identity_id must be provided."
  }

  validation {
    condition = var.vault.identity == null || (
      var.vault.identity != null &&
      var.vault.identity.type == "UserAssigned" ? length(var.vault.identity.identity_ids) > 0 : true
    )
    error_message = "When identity type is 'UserAssigned', at least one identity_id must be provided."
  }

  validation {
    condition = alltrue([
      for policy_name, policy in coalesce(var.vault.policies.vms, {}) :
      policy.instant_restore_retention_days == null || (
        policy.instant_restore_retention_days != null &&
        policy.instant_restore_retention_days >= 1 &&
        policy.instant_restore_retention_days <= 30
      )
    ])
    error_message = "instant_restore_retention_days must be between 1 and 30 days when specified."
  }

  validation {
    condition = alltrue([
      for policy_name, policy in coalesce(var.vault.policies.vms, {}) :
      policy.backup.frequency == "Hourly" ? (
        policy.backup.hour_interval != null &&
        policy.backup.hour_duration != null &&
        policy.backup.hour_interval >= 4 &&
        policy.backup.hour_interval <= 24 &&
        policy.backup.hour_duration >= 4 &&
        policy.backup.hour_duration <= 24
      ) : true
    ])
    error_message = "For hourly backup frequency, hour_interval and hour_duration must be between 4 and 24 hours."
  }

  validation {
    condition = alltrue([
      for policy_name, policy in coalesce(var.vault.policies.vms, {}) :
      policy.backup.frequency == "Weekly" ? policy.backup.weekdays != null : true
    ])
    error_message = "When backup frequency is 'Weekly', weekdays must be specified."
  }

  validation {
    condition = alltrue([
      for policy_name, policy in coalesce(var.vault.policies.file_shares, {}) :
      policy.retention.monthly != null ? (
        policy.retention.monthly.include_last_days == true ? (
          policy.retention.monthly.weekdays == null &&
          policy.retention.monthly.weeks == null
        ) : true
      ) : true
    ])
    error_message = "For file share monthly retention: when include_last_days is true, weekdays and weeks must not be specified."
  }

  validation {
    condition = alltrue([
      for policy_name, policy in coalesce(var.vault.policies.vms, {}) :
      policy.retention.monthly != null ? (
        policy.retention.monthly.include_last_days == true ? (
          policy.retention.monthly.weekdays == null &&
          policy.retention.monthly.weeks == null
        ) : true
      ) : true
    ])
    error_message = "For VM monthly retention: when include_last_days is true, weekdays and weeks must not be specified."
  }
}

variable "naming" {
  description = "contains naming convention"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}

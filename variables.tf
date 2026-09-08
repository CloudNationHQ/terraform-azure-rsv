variable "vault" {
  description = "Contains all recovery services vault configuration"
  type = object({
    name                               = string
    resource_group_name                = optional(string)
    location                           = optional(string)
    sku                                = optional(string, "Standard")
    immutability                       = optional(string)
    cross_region_restore_enabled       = optional(bool)
    storage_mode_type                  = optional(string)
    public_network_access_enabled      = optional(bool)
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
      use_system_assigned_identity      = optional(bool)
    }), null)
    monitoring = optional(object({
      alerts_for_all_job_failures_enabled            = optional(bool)
      alerts_for_critical_operation_failures_enabled = optional(bool)
      alerts_for_all_failover_issues_enabled         = optional(bool)
      alerts_for_all_replication_issues_enabled      = optional(bool)
      email_notifications_for_site_recovery_enabled  = optional(bool)
    }), null)
    policies = optional(object({
      file_shares = optional(map(object({
        name                       = optional(string)
        timezone                   = optional(string)
        backup_tier                = optional(string)
        snapshot_retention_in_days = optional(number)
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
            include_last_days = optional(bool)
          }), null)
          yearly = optional(object({
            count             = optional(number)
            weekdays          = optional(set(string))
            weeks             = optional(set(string))
            months            = optional(set(string))
            days              = optional(set(number))
            include_last_days = optional(bool)
          }), null)
        })
        protected_shares = optional(map(object({
          name               = string
          storage_account_id = string
        })), {})
      })), {})
      vms = optional(map(object({
        name                           = optional(string)
        timezone                       = optional(string)
        policy_type                    = optional(string)
        consistency_type               = optional(string)
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
            weekdays          = optional(set(string))
            weeks             = optional(set(string))
            days              = optional(set(number))
            include_last_days = optional(bool)
          }), null)
          yearly = optional(object({
            count             = optional(number)
            weekdays          = optional(set(string))
            weeks             = optional(set(string))
            months            = optional(set(string))
            days              = optional(set(number))
            include_last_days = optional(bool)
          }), null)
        })
        protected_vms = optional(map(object({
          id                = string
          include_disk_luns = optional(list(number))
          exclude_disk_luns = optional(list(number))
          protection_state  = optional(string)
        })), {})
      })), {})
      vm_workloads = optional(map(object({
        name          = optional(string)
        workload_type = string
        settings = object({
          time_zone           = string
          compression_enabled = optional(bool)
        })
        protection_policies = map(object({
          policy_type = string
          backup = object({
            frequency            = optional(string)
            frequency_in_minutes = optional(number)
            time                 = optional(string)
            weekdays             = optional(set(string))
          })
          retention_daily = optional(object({
            count = number
          }), null)
          retention_weekly = optional(object({
            count    = number
            weekdays = set(string)
          }), null)
          retention_monthly = optional(object({
            count       = number
            format_type = string
            monthdays   = optional(set(number))
            weekdays    = optional(set(string))
            weeks       = optional(set(string))
          }), null)
          retention_yearly = optional(object({
            count       = number
            format_type = string
            months      = set(string)
            monthdays   = optional(set(number))
            weekdays    = optional(set(string))
            weeks       = optional(set(string))
          }), null)
          simple_retention = optional(object({
            count = number
          }), null)
        }))
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

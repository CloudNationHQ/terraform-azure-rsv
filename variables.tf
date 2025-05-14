variable "vault" {
  description = "Contains all recovery services vault configuration"
  type = object({
    name                               = string
    resource_group_name                = optional(string, null)
    location                           = optional(string, null)
    sku                                = optional(string, "Standard")
    soft_delete_enabled                = optional(bool, false)
    immutability                       = optional(string, "Disabled")
    cross_region_restore_enabled       = optional(bool, null)
    storage_mode_type                  = optional(string, "GeoRedundant")
    public_network_access_enabled      = optional(bool, true)
    classic_vmware_replication_enabled = optional(bool, null)
    tags                               = optional(map(string))
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
    }), null)
    encryption = optional(object({
      key_id                            = string
      infrastructure_encryption_enabled = bool
      user_assigned_identity_id         = optional(string, null)
      use_system_assigned_identity      = optional(bool, true)
    }), null)
    monitoring = optional(object({
      alerts_for_all_job_failures_enabled            = optional(bool, true)
      alerts_for_critical_operation_failures_enabled = optional(bool, true)
    }), null)
    policies = optional(object({
      file_shares = optional(map(object({
        name     = optional(string, null)
        timezone = optional(string, "UTC")
        backup = object({
          frequency = string
          time      = optional(string, null)
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
            count    = optional(number, null)
            weekdays = optional(list(string), [])
          }), null)
          monthly = optional(object({
            count             = optional(number, null)
            weekdays          = optional(list(string), null)
            weeks             = optional(list(string), null)
            days              = optional(list(number), null)
            include_last_days = optional(bool, null)
          }), null)
          yearly = optional(object({
            count             = optional(number, null)
            weekdays          = optional(list(string), [])
            weeks             = optional(list(string), [])
            months            = optional(list(string), [])
            days              = optional(list(number), null)
            include_last_days = optional(bool, false)
          }), null)
        })
        protected_shares = optional(map(object({
          name               = string
          storage_account_id = string
        })), {})
      })), {})
      vms = optional(map(object({
        name                           = optional(string, null)
        timezone                       = optional(string, "UTC")
        policy_type                    = optional(string, "V1")
        instant_restore_retention_days = optional(number, null)
        instant_restore_resource_group = optional(object({
          prefix = string
          suffix = optional(string, null)
        }), null)
        tiering_policy = optional(object({
          archived_restore_point = optional(object({
            mode          = string
            duration      = optional(number, null)
            duration_type = optional(string, null)
          }), null)
        }), null)
        backup = object({
          frequency     = string
          time          = string
          hour_interval = optional(number, null)
          hour_duration = optional(number, null)
          weekdays      = optional(list(string), null)
        })
        retention = object({
          daily = optional(object({
            count = optional(number, null)
          }), null)
          weekly = optional(object({
            count    = optional(number, null)
            weekdays = optional(list(string), null)
          }), null)
          monthly = optional(object({
            count             = optional(number, null)
            weekdays          = optional(list(string), [])
            weeks             = optional(list(string), [])
            days              = optional(list(string), [])
            include_last_days = optional(bool, false)
          }), null)
          yearly = optional(object({
            count             = optional(number, null)
            weekdays          = optional(list(string), [])
            weeks             = optional(list(string), [])
            months            = optional(list(string), [])
            days              = optional(list(string), [])
            include_last_days = optional(bool, false)
          }), null)
        })
        protected_vms = optional(map(object({
          id                = string
          include_disk_luns = optional(list(number), null)
          exclude_disk_luns = optional(list(number), null)
          protection_state  = optional(string, null)
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

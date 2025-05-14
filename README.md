# Recovery Service Vault

This terraform module streamlines the setup and management of azure recovery services vaults, offering tailored options for backup policies.

## Features

Enables creation of multiple policies for file shares and VMs

Utilization of terratest for robust validation

Integrates seamlessly with private endpoint capabilities for direct and secure connectivity

Simplifies item policy association

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_backup_container_storage_account.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_container_storage_account) (resource)
- [azurerm_backup_policy_file_share.policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_file_share) (resource)
- [azurerm_backup_policy_vm.policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_vm) (resource)
- [azurerm_backup_protected_file_share.share](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_file_share) (resource)
- [azurerm_backup_protected_vm.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm) (resource)
- [azurerm_recovery_services_vault.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_vault"></a> [vault](#input\_vault)

Description: Contains all recovery services vault configuration

Type:

```hcl
object({
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_naming"></a> [naming](#input\_naming)

Description: contains naming convention

Type: `map(string)`

Default: `{}`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_vault"></a> [vault](#output\_vault)

Description: Contains all recovery services vault configuration
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-rsv/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-rsv" />
</a>

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/backup/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/recoveryservices/)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/blob/1f449b5a17448f05ce1cd914f8ed75a0b568d130/specification/recoveryservicesbackup/resource-manager/Microsoft.RecoveryServices/stable/2023-02-01/bms.json)

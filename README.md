# Recovery Service Vault

This terraform module streamlines the setup and management of azure recovery services vaults, offering tailored options for backup policies.

## Goals

The main objective is to create a more logic data structure, achieved by combining and grouping related resources together in a complex object.

The structure of the module promotes reusability. It's intended to be a repeatable component, simplifying the process of building diverse workloads and platform accelerators consistently.

A primary goal is to utilize keys and values in the object that correspond to the REST API's structure. This enables us to carry out iterations, increasing its practical value as time goes on.

A last key goal is to separate logic from configuration in the module, thereby enhancing its scalability, ease of customization, and manageability.

## Non-Goals

These modules are not intended to be complete, ready-to-use solutions; they are designed as components for creating your own patterns.

They are not tailored for a single use case but are meant to be versatile and applicable to a range of scenarios.

Security standardization is applied at the pattern level, while the modules include default values based on best practices but do not enforce specific security standards.

End-to-end testing is not conducted on these modules, as they are individual components and do not undergo the extensive testing reserved for complete patterns or solutions.

## Features

- enables creation of multiple policies for file shares and VMs
- utilization of terratest for robust validation
- integrates seamlessly with private endpoint capabilities for direct and secure connectivity
- simplifies item policy association

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_backup_container_storage_account.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_container_storage_account) | resource |
| [azurerm_backup_policy_file_share.policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_file_share) | resource |
| [azurerm_backup_policy_vm.policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_vm) | resource |
| [azurerm_backup_protected_file_share.share](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_file_share) | resource |
| [azurerm_backup_protected_vm.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm) | resource |
| [azurerm_recovery_services_vault.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | default azure region to be used. | `string` | `null` | no |
| <a name="input_naming"></a> [naming](#input\_naming) | contains naming convention | `map(string)` | `{}` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | default resource group to be used. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tags to be added to the resources | `map(string)` | `{}` | no |
| <a name="input_vault"></a> [vault](#input\_vault) | describes recovery services vault related configuration | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vault"></a> [vault](#output\_vault) | n/a |
<!-- END_TF_DOCS -->

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/terraform-azure-rsv/graphs/contributors).

## Contributing

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md).

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/backup/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/recoveryservices/)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/blob/1f449b5a17448f05ce1cd914f8ed75a0b568d130/specification/recoveryservicesbackup/resource-manager/Microsoft.RecoveryServices/stable/2023-02-01/bms.json)

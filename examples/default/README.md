This example illustrates the default recovery services vault setup, in its simplest form.

## Usage: default

```hcl
module "rsv" {
  source  = "cloudnationhq/rsv/azure"
  version = "~> 0.4"

  vault = {
    name          = module.naming.recovery_services_vault.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
  }
}
```

## Usage: multiple

Additionally, for certain scenarios, the example below highlights the ability to use multiple vaults, enabling a broader setup.

```hcl
module "rsv" {
  source = "cloudnationhq/rsv/azure"
  version = "~> 0.1"

  for_each = local.vault

  naming = local.naming
  vault  = each.value
}
```

The module uses a local to iterate, generating a recovery services vault for each key.

```hcl
locals {
  vault = {
    vault1 = {
      name          = "rsv-demo-dev-weu"
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name
      policies = {
        vms = {
          weu = {
            timezone = "W. Europe Standard Time"
            backup = {
              frequency = "Daily"
              time      = "23:00"
            }
            retention = {
              daily = {
                count = 7
              }
            }
          }
        }
      }
    }
    vault2 = {
      name          = "rsv-demo-dev-sea"
      location      = module.rg.groups.demo2.location
      resourcegroup = module.rg.groups.demo2.name
      policies = {
        vms = {
          sea = {
            timezone = "Singapore Standard Time"
            backup = {
              frequency = "Daily"
              time      = "23:00"
            }
            retention = {
              daily = {
                count = 7
              }
            }
          }
        }
      }
    }
  }
}
```

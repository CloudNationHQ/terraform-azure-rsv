This example highlights recovery services vault policies using different types.

## Usage: vm

```hcl
module "rsv" {
  source  = "cloudnationhq/rsv/azure"
  version = "~> 0.4"

  naming = local.naming

  vault = {
    name          = module.naming.recovery_services_vault.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    policies = {
      vms = {
        pol1 = {
          timezone = "UTC"
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
```

## Usage: file shares

```hcl
module "rsv" {
  source  = "cloudnationhq/rsv/azure"
  version = "~> 0.1"

  naming = local.naming

  vault = {
    name          = module.naming.recovery_services_vault.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    policies = {
      file_shares = {
        pol1 = {
          timezone = "UTC"
          backup = {
            frequency = "Daily"
            time      = "23:00"
          }
          retention = {
            daily = {
              count = 3
            }
            weekly = {
              count    = 2
              weekdays = ["Monday", "Tuesday"]
            }
            monthly = {
              count    = 1
              weekdays = ["Monday"]
              weeks    = ["First"]
            }
          }
        }
      }
    }
  }
}
```

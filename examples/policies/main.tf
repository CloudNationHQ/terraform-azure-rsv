module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.22"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "rsv" {
  source  = "cloudnationhq/rsv/azure"
  version = "~> 1.0"

  naming = local.naming

  vault = {
    name           = module.naming.recovery_services_vault.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name

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

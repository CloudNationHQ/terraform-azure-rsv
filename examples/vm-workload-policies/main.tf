module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.25"

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
  version = "~> 2.0"

  naming = local.naming

  vault = {
    name                = module.naming.recovery_services_vault.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    policies = {
      vm_workloads = {
        sqlserver = {
          workload_type = "SQLDataBase"
          settings = {
            time_zone           = "UTC"
            compression_enabled = false
          }
          protection_policies = {
            full = {
              policy_type = "Full"
              backup = {
                frequency = "Weekly"
                time      = "23:00"
                weekdays  = ["Sunday"]
              }
              retention_weekly = {
                count    = 8
                weekdays = ["Sunday"]
              }
            }
            log = {
              policy_type = "Log"
              backup = {
                frequency_in_minutes = 15
              }
              simple_retention = {
                count = 8
              }
            }
          }
        }
      }
    }
  }
}

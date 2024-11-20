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

  vault = {
    name           = module.naming.recovery_services_vault.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
  }
}

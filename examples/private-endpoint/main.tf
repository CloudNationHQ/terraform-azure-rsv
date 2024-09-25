module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name
      location = "westeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 4.0"

  naming = local.naming

  vnet = {
    name           = module.naming.virtual_network.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    cidr           = ["10.19.0.0/16"]

    subnets = {
      sn1 = {
        nsg  = {}
        cidr = ["10.19.1.0/24"]
      }
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

    public_network_access_enabled = false
  }
}

module "private_dns" {
  source  = "cloudnationhq/pdns/azure"
  version = "~> 2.0"

  resource_group = module.rg.groups.demo.name

  zones = {
    vault = {
      name = "privatelink.we.backup.windowsazure.com"
      virtual_network_links = {
        link1 = {
          virtual_network_id   = module.network.vnet.id
          registration_enabled = true
        }
      }
    }
  }
}

module "privatelink" {
  source  = "cloudnationhq/pe/azure"
  version = "~> 1.0"

  resource_group = module.rg.groups.demo.name
  location       = module.rg.groups.demo.location

  endpoints = local.endpoints
}

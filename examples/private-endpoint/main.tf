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

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 8.0"

  naming = local.naming

  vnet = {
    name           = module.naming.virtual_network.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    address_space  = ["10.19.0.0/16"]

    subnets = {
      sn1 = {
        address_prefixes       = ["10.19.1.0/24"]
        network_security_group = {}
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
  version = "~> 3.0"

  resource_group = module.rg.groups.demo.name

  zones = {
    private = {
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
}

module "privatelink" {
  source  = "cloudnationhq/pe/azure"
  version = "~> 1.0"

  resource_group = module.rg.groups.demo.name
  location       = module.rg.groups.demo.location

  endpoints = {
    vault = {
      name                           = module.naming.private_endpoint.name
      subnet_id                      = module.network.subnets.sn1.id
      private_connection_resource_id = module.rsv.vault.id
      private_dns_zone_ids           = [module.private_dns.private_zones.vault.id]
      subresource_names              = ["AzureBackup"]
    }
  }
}

module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.32"

  suffix = ["demo", "prd"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 10.0"


  vnet = {
    name                = module.naming.virtual_network.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    address_space       = ["10.18.0.0/16"]

    subnets = {
      int = {
        address_prefixes       = ["10.18.1.0/24"]
        network_security_group = {}
      }
      mgt = {
        address_prefixes       = ["10.18.2.0/24"]
        network_security_group = {}
      }
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 6.0"


  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    secrets = {
      random_string = {
        dcroot001 = {
          length  = 24
          special = false
        }
        dcroot002 = {
          length  = 24
          special = false
        }
      }
    }
  }
}

module "vm" {
  source  = "cloudnationhq/vm/azure"
  version = "~> 8.0"

  for_each = local.vms

  virtual_machine     = each.value
  resource_group_name = module.rg.groups.demo.name
  location            = module.rg.groups.demo.location

  source_image_reference = {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

module "rsv" {
  source  = "cloudnationhq/rsv/azure"
  version = "~> 3.0"

  vault = {
    name                = module.naming.recovery_services_vault.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    policies            = local.policies
  }
}

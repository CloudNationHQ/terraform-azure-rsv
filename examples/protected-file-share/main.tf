module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["hello", "devil"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 0.1"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 0.1"

  naming = local.naming

  storage = {
    name          = module.naming.storage_account.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    network_rules = {
      default_action             = "Allow"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }
    share_properties = {
      smb = {
        versions             = ["SMB3.1.1"]
        authentication_types = ["Kerberos"]
      }

      shares = {
        share1 = {
          quota = 5
          metadata = {
            environment = "PRD"
          }
        },
        share2 = {
          quota = 5
          metadata = {
            environment = "PRD"
          }
        }
      }
    }
  }
}


module "rsv" {

  source  = "cloudnationhq/rsv/azure"
  version = "~> 0.1"

  naming                   = local.naming
  storage_account_id       = module.storage.account.id
  file_shares              = local.share_names
  enable_file_share_backup = true


  vault = {
    name          = module.naming.recovery_services_vault.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    policies      = local.policies
  }
}

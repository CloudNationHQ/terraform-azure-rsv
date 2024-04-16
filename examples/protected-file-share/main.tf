module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "prd"]
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

      retention_policy = {
        days = 30
      }

      shares = {
        share1 = {
          quota = 512
          metadata = {
            environment = "PRD"
          }
        },
        share2 = {
          quota = 512
          metadata = {
            environment = "PRD"
          }
        }
      }
    }
  }
}


module "rsv" {
  source = "git::https://github.com/CloudNationHQ/terraform-azure-rsv.git?ref=feat/enable-fileshare-backup"
  # source = "cloudnationhq/rsv/azure"
  # version = "~> 0.1"

  naming             = local.naming
  storage_account_id = module.storage.account.id

  vault = {
    name          = module.naming.recovery_services_vault.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    policies = local.policies
  }
}

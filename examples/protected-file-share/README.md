This example demonstrates associating multiple VMs to a policy.

## Usage:

Storage  account is created in the below example:

```hcl
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

```


In the below example, a policy of type file share is created, it also create a Backup Container which assosiates the Azure Storage account to be part of the Recovery Service Vault

```hcl
module "rsv" {
  # source = "git::https://github.com/CloudNationHQ/terraform-azure-rsv.git?ref=feat/enable-fileshare-backup"
  # source = "cloudnationhq/rsv/azure"
  # version = "~> 0.1"
  source = "../../"

  naming                   = local.naming
  storage_account_id       = module.storage.account.id
  file_shares              = local.share_names
  enable_file_share_backup = true # If you want to enable file share backup


  vault = {
    name          = module.naming.recovery_services_vault.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    policies      = local.policies
  }
}
```

Create the policies

```hcl
locals {
  policies = {
    file_shares = {
      for share_names in local.share_names : share_names => {
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
    source_storage_account_id = module.storage.account.id
  }
}

```

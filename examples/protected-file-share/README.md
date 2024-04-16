This example demonstrates associating multiple VMs to a policy.

## Usage:

Storage  account is created in the below example:

```hcl
odule "storage" {
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

```


In the below example, a policy of type file share is created.

```hcl
module "rsv" {
  source  = "cloudnationhq/rsv/azure"
  version = "~> 0.1"
  storage_account_id = module.storage.account.id

  vault = {
    name          = module.naming.recovery_services_vault.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    policies      = local.policies
  }
}
```

```hcl
locals {
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
        protected_file_shares = {
          share1 = {
            id = module.storage.shares.share1.id
          },
          share2 = {
            id = module.storage.shares.share2.id
          }
        }
      }
    }
    source_storage_account_id = module.storage.account.id
  }
}

```

The module output below is needed, because we iterate over the VM module.

```hcl
output "instance" {
  sensitive = true
  value = {
    for k, module_instance in module.vm : k => module_instance.instance
  }
}
```

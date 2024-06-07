This example demonstrates associating multiple VMs to a policy.

## Usage:

Several Vms are created in the below example:

```hcl
module "vm" {
  source  = "cloudnationhq/vm/azure"
  version = "~> 0.3"

  naming        = local.naming
  keyvault      = module.kv.vault.id
  resourcegroup = module.rg.groups.demo.name
  location      = module.rg.groups.demo.location
  depends_on    = [module.kv]

  for_each = local.vms

  instance = each.value
}
```

It utilizes the below locals for configuration:

```hcl
locals {
  vms = {
    dcroot001 = {
      name = "vmdcroot001"
      type = "windows"
      size = "Standard_D2s_v5"
      interfaces = {
        int1 = {
          name   = "vmdcroot-int1"
          subnet = module.network.subnets.int.id
        }
      }
      disks = {
        dsk1 = {
          name         = "vmdcroot001-dsk1"
          disk_size_gb = 128
        }
      }
    }
    dcroot002 = {
      name = "vmdcroot002"
      type = "windows"
      size = "Standard_D4ds_v5"
      interfaces = {
        int1 = {
          name   = "vmdcroot002-int1"
          subnet = module.network.subnets.mgt.id
        }
      }
      disks = {
        dsk1 = {
          name         = "vmdcroot002-dsk1"
          disk_size_gb = 128
        }
      }
    }
  }
}
```

In the below example, a policy of type azure virtual machine is created to associate multiple VMs.

```hcl
module "rsv" {
  source  = "cloudnationhq/rsv/azure"
  version = "~> 0.1"

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
    vms = {
      demo = {
        name     = "demosdsd"
        timezone = "UTC"
        backup = {
          frequency = "Daily"
          time      = "23:00"
        }
        retention = {
          daily = {
            count = 7
          }
        }
        protected_vms = {
          dcroot001 = {
            id = module.vm["dcroot001"].instance.id
          }
          dcroot002 = {
            id = module.vm["dcroot002"].instance.id
          }
        }
      }
    }
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

This example illustrates the default sql server setup, in its simplest form.

## Usage:

```hcl
module "rsv" {
  source  = "cloudnationhq/rsv/azure"
  version = "~> 0.1"

  vault = {
    name          = module.naming.recovery_services_vault.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
  }
}
```

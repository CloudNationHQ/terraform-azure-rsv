This example details a recovery services vault setup with a private endpoint, enhancing security by restricting data access to a private network.

## Usage: private endpoint

```hcl
module "privatelink" {
  source  = "cloudnationhq/pe/azure"
  version = "~> 0.2"

  resourcegroup = module.rg.groups.demo.name
  location      = module.rg.groups.demo.location

  endpoints = local.endpoints
}
```

The module uses the below locals for configuration:

```hcl
locals {
  endpoints = {
    vault = {
      name                           = module.naming.private_endpoint.name
      subnet_id                      = module.network.subnets.sn1.id
      private_connection_resource_id = module.rsv.vault.id
      private_dns_zone_ids           = [module.private_dns.zones.vault.id]
      subresource_names              = ["AzureBackup"]
    }
  }
}
```

The below module call is used to manage the private DNS zone:

```hcl
module "private_dns" {
  source  = "cloudnationhq/pdns/azure"
  version = "~> 0.1"

  resourcegroup = module.rg.groups.demo.name

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
```

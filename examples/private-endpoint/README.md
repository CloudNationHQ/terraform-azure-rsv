# Private Endpoint

This deploys private endpoints

## Types

```hcl
resource_group = string
location       = string
endpoints = map(object({
  name                           = string
  subnet_id                      = string
  private_connection_resource_id = string
  private_dns_zone_ids          = list(string)
  subresource_names             = list(string)
}))
```

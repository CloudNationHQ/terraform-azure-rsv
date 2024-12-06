# Protected File Shares

This deploys policies and associations to include file shares

## Types

```hcl
vault = object({
  name           = string
  location       = string
  resource_group = string
  policies = optional(object({
    file_shares = optional(map(object({
      name     = optional(string)
      timezone = optional(string)
      backup = object({
        frequency = string
        time      = string
      })
      retention = object({
        daily = object({
          count = number
        })
        weekly = optional(object({
          count    = number
          weekdays = list(string)
        }))
        monthly = optional(object({
          count    = number
          weekdays = list(string)
          weeks    = list(string)
        }))
        yearly = optional(object({
          count    = number
          weekdays = list(string)
          weeks    = list(string)
          months   = list(string)
        }))
      })
      protected_shares = optional(map(object({
        name               = string
        storage_account_id = string
      })))
    })))
  }))
})
```

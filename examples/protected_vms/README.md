# Protected Virtual Machines

This deploys policies and associations to include virtual machines

## Types

```hcl
vault = object({
  name           = string
  location       = string
  resource_group = string
  policies = optional(object({
    vms = optional(map(object({
      name         = optional(string)
      timezone     = optional(string)
      policy_type  = optional(string)
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
        yearly = optional(object({
          count    = number
          weekdays = list(string)
          weeks    = list(string)
          months   = list(string)
        }))
      })
      protected_vms = optional(map(object({
        id = string
      })))
    })))
  }))
})
```

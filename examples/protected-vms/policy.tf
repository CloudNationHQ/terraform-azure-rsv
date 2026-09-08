locals {
  policies = {
    vms = {
      daily = {
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
            id = module.vm["dcroot001"].virtual_machine.id
          }
          dcroot002 = {
            id = module.vm["dcroot002"].virtual_machine.id
          }
        }
      }
    }
  }
}

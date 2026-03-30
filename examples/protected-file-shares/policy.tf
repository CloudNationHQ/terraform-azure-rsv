locals {
  policies = {
    file_shares = {
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
        protected_shares = {
          fs1 = {
            name               = module.storage.shares.fs1.name
            storage_account_id = module.storage.account.id
          }
          fs2 = {
            name               = module.storage.shares.fs2.name
            storage_account_id = module.storage.account.id
          }
        }
      }
    }
  }
}

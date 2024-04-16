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

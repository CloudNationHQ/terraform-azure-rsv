locals {
  policies = {
    file_shares = {
      for share_names in local.share_names : share_names => {
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
      }
    }
    source_storage_account_id = module.storage.account.id
  }
}

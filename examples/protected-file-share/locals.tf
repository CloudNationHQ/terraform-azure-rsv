locals {
  naming = {
    # lookup outputs to have consistent naming
    for type in local.naming_types : type => lookup(module.naming, type).name
  }

  naming_types = ["storage_share", "recovery_services_vault_backup_policy"]

  share_names = [for s in module.storage.shares : s.name]
}

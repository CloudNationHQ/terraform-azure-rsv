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

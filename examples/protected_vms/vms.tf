locals {
  vms = {
    dcroot001 = {
      name = "vmdcroot001"
      type = "windows"
      size = "Standard_D2s_v5"
      interfaces = {
        int1 = {
          name   = "vmdcroot-int1"
          subnet = module.network.subnets.int.id
          ip_configurations = {
            config1 = {
              primary                       = true
              private_ip_address_allocation = "Dynamic"
            }
          }
        }
      }
      disks = {
        dsk1 = {
          name         = "vmdcroot001-dsk1"
          disk_size_gb = 128
          lun          = 0
        }
      }
    }
    dcroot002 = {
      name = "vmdcroot002"
      type = "windows"
      size = "Standard_D4ds_v5"
      interfaces = {
        int1 = {
          name   = "vmdcroot002-int1"
          subnet = module.network.subnets.mgt.id
          ip_configurations = {
            config1 = {
              primary                       = true
              private_ip_address_allocation = "Dynamic"
            }
          }
        }
      }
      disks = {
        dsk1 = {
          name         = "vmdcroot002-dsk1"
          disk_size_gb = 128
          lun          = 0
        }
      }
    }
  }
}

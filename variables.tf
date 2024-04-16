variable "vault" {
  description = "describes recovery services vault related configuration"
  type        = any
}

variable "naming" {
  description = "contains naming convention"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resourcegroup" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}

variable "storage_account_id" {
  description = "storage account id to be used to manages registration of a storage account with an Azure Recovery Vault"
  type        = string
  default     = null
}

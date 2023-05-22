variable "workspaceName" {}
variable "trimmed_workspaceName" {}

variable "storageAccountTier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. Defaults to Standard."

  type    = string
  default = "Standard"
}

variable "storageAccessTier" {
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot."

  type    = string
  default = "Hot"
}

variable "researchdrive" {
  description = "Set to true to mount an existing Researchdrive instance"

  type = bool
  default = "false"
}

variable "region" {
  description = "The Azure region the VRE should be placed in."

  type    = string
  default = "westeurope"
}

variable "tags" {
  description = "Key value pair to tag all resources"
  type        = map(string)
  default     = {}
}

variable "azFileStorage" {
  description = "Set to true to enable creation of a storage file share on the workspace storage account"

  type    = bool
  default = "false"
}
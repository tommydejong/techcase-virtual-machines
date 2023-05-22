variable "projectName" {}
variable "workspaceName" {}
variable "trimmed_workspaceName" {}

variable "region" {
  description = "The Azure region the VRE should be placed in."

  type    = string
  default = "westeurope"
}

variable "autoShutdownSchedule" {
  description = "Define an AutoShutDownSchedule here. Example value: \"20:00->08:00, Saturday, Sunday\". More info at: https://github.com/tomasrudh/AutoShutdownSchedule#schedule-tag-examples"

  type    = string
  default = ""
}

variable "vmSize" {
  description = "The size of the VM used for the VRE. To get a list of available VM sizes use az vm list-sizes --location \"westeurope\" -otable. Example values: Standard_NC6_promo, Standard_B4ms"

  type    = string
  default = ""

  # validation {
  #   condition     = can(regex("^(Standard_)", var.vmSize))
  #   error_message = "The VM SKU must start with 'Standard_'. To get a list of available VM sizes use az vm list-sizes --location \"westeurope\" -otable."
  # }
}

variable "vmSizeMapping" {
  description = "The size of the VM used for the VRE. This maps potential values in the frontend to their respective size in Azure."

  default = {
    "Small"  = "Standard_B4ms"
    "Medium" = "Standard_D8s_v5"
    "GPU"    = "Standard_NC6_Promo"
    "Memory" = "Standard_E8ds_v5"
  }
}

variable "osdiskSku" {
  description = "The SKU used for the OS Disk. Possible values: Standard_LRS, Premium_LRS, StandardSSD_LRS or UltraSSD_LRS"

  type    = string
  default = "StandardSSD_LRS"

  # validation {
  #   condition     = can(regex("^(Standard_LRS|Premium_LRS|StandardSSD_LRS|UltraSSD_LRS)$", var.osdiskSku))
  #   error_message = "The disk SKU must be one of: Standard_LRS, Premium_LRS, StandardSSD_LRS or UltraSSD_LRS."
  # }
}

variable "diskSkuMapping" {
  description = "The types of disks that are available in Azure. This maps potential values in the frontend to their respective size in Azure."

  default = {
    "HDD"     = "Standard_LRS"
    "SSD"     = "StandardSSD_LRS"
    "Premium" = "Premium_LRS"
    "Ultra"   = "UltraSSD_LRS"
  }
}

variable "osdiskSize" {
  description = "The size in GB of the OS Disk."

  type    = number
  default = 128

  validation {
    condition     = can(regex("[0-9]+", var.osdiskSize))
    error_message = "Must be a whole number."
  }
}

variable "osType" {
  description = "The OS type of the VRE. Must be either windows or linux."
  type        = string

  validation {
    condition     = can(regex("^(windows|linux)$", var.osType))
    error_message = "Must be either windows or linux."
  }
}

variable "software" {
  type = list(object({
    name    = string
    version = string
  }))
  description = "A list of software packages to install. Example: [\"rstudio\", \"qdaminer\"]"
  default     = []
}

# Access and firewall rules
variable "allowUvaVPN" {
  type    = bool
  default = false
}

variable "allowHvaVPN" {
  type    = bool
  default = false
}

variable "allowEduVPN" {
  type    = bool
  default = false
}

variable "remoteAccessRules" {
  type        = any
  description = "A list of IP addresses that should have access to the VRE."
  default     = {}
}

variable "firewallRules" {
  type        = any
  description = "A list of firewall rules to add to the security group. Each rule should be a map of values to add"
  default     = {}
}


variable "customDomainName" {
  description = "Provide a custom domain name for the VRE. The value will be added to the public IP address, and will result in the following domain name: `<value>`.`<location>`.cloudapp.azure.com"

  type    = string
  default = ""
}

variable "storageAccountName" {
  description = "The existing storage account that should be linked to this VRE instance"

  type    = string
  default = ""
}

variable "workspaceRG" {
  description = "The workspace resource group where the VRE should be created in"

  type    = string
  default = ""
}

variable "tags" {
  description = "Key value pair to tag all resources"
  type        = map(string)
  default     = {}
}

variable "jcApiKey" {
  description = "The API key of the JumpCloud instance this VRE is added to."

  type      = string
  default   = ""
  sensitive = true
}

variable "researchdrive" {
  description = "Set to true to connect an existing ResearchDrive to this VRE. If true, be sure to specify a rDriveKey and rDriveUser"

  type    = bool
  default = "false"
}
variable "rDriveKey" {
  description = "The key that will be used to connect to ResearchDrive."

  type      = string
  default   = ""
  sensitive = true
}

variable "rDriveUser" {
  description = "The username/e-mail address that will be used to connect to ResearchDrive."

  type      = string
  default   = ""
  sensitive = true
}

variable "azFileStorage" {
  description = "Set to true to enable creation of a storage file share on the workspace storage account"

  type    = bool
  default = "false"
}
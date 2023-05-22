variable "uva_subscription_id" {
  type = string
}

variable "hva_subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "azureRegion" {
  type    = string
  default = "westeurope"
}

variable "osDiskSize" {
  type    = number
  default = 128
}

variable "vmSize" {
  type    = string
  default = "Standard_DS2_v2"
}
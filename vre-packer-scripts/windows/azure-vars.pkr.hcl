variable "subscription_id" {
  type = string
  default = "582089b7-6ffa-47b0-8b9b-65f7c583852b"
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
  default = "Standard_D2_v2"
}
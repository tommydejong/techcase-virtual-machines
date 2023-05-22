# Enable this if you want shared configuration from a terragrunt.hcl file in the parent (root) folder
# include {
#   path = find_in_parent_folders()
# }

terraform {
  source = "../../tf-modules/vre-storage/module"
  #source = "git::https://gitlab.ic.uva.nl/vre/vre-tf-modules/vre-storage.git//module?ref=${local.vars.versions.storage}"
}

prevent_destroy = true

remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    resource_group_name          = "core-rg"
    storage_account_name         = get_env("VRE_STATES_SA")
    container_name               = "terraform-states"
    key                          = "${local.vars.workspaceName}.terraform.tfstate"
  }
}

locals {
  vars = read_terragrunt_config("${find_in_parent_folders("variables.hcl")}").locals
}

inputs = merge(
  local.vars,
  local.vars.vreconfig
)

generate "providers" {
  path = "providers.tf"
  if_exists = "overwrite"
  contents = <<EOF
    provider "azurerm" {
      features {}
      subscription_id = "${get_env("ARM_SUBSCRIPTION_ID")}"
    }
  EOF
}

generate "versions" {
  path = "versions.tf"
  if_exists = "overwrite"
  contents = <<EOF
    terraform {
      required_version = ">= ${local.vars.versions.tf}"
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> ${local.vars.versions.azurerm}"
        }
      }
    }
  EOF
}
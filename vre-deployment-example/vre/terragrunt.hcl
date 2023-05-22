# Enable this if you want shared configuration from a terragrunt.hcl file in the parent (root) folder
# include {
#   path = find_in_parent_folders()
# }

dependency "storage" {
  config_path  = "../storage"
}

locals {
  vars = read_terragrunt_config("${find_in_parent_folders("variables.hcl")}").locals

  timestamp      = replace(timestamp(), "[- TZ:]", "")
  formatted_date = formatdate("YYYY.MM.DD", timestamp())
  tfstate_blob   = "${local.vars.workspaceName}.vre.terraform.tfstate"
}

inputs = merge(
  local.vars,
  local.vars.vreconfig,
  {
    workspaceRG = dependency.storage.outputs.master_workspace_rg
    storageAccountName = dependency.storage.outputs.master_storage_account_name
  }
)

terraform {
  source = "../../tf-modules/${local.vars.vreconfig.cloud}-vre/module"
  #source = "git::https://gitlab.ic.uva.nl/vre/vre-tf-modules/${local.vars.vreconfig.cloud}-vre.git//module?ref=${local.vars.versions.vre}"

  before_hook "before_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "Running Terraform"]
    run_on_error = true
  }

  before_hook "before_hook_destroy-snapshot" {
    commands     = ["destroy"]
    execute      = ["bash", "${find_in_parent_folders("create_az_snapshot.sh")}", "${local.vars.workspaceName}", "terraform-states", "${local.tfstate_blob}", "${dependency.storage.outputs.master_storage_account_name}"]
    run_on_error = false
  }

  after_hook "after_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "Finished running Terraform"]
    run_on_error = true
  }

  after_hook "after_hook_apply-configs" {
    commands     = ["apply"]
    execute      = ["bash", "${find_in_parent_folders("upload_vre_config_blob.sh")}", "${dependency.storage.outputs.master_storage_account_name}", "${dependency.storage.outputs.master_workspace_rg}", "vre-config.yml", "vre-versions.yml", "${dependency.storage.outputs.primary_access_key}"]
    run_on_error = false
  }
}

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
    key                          = "${local.tfstate_blob}"
  }
}

generate "providers" {
  path = "providers.tf"
  if_exists = "overwrite"
  contents = <<EOF
    provider "azurerm" {
      features {
        virtual_machine {
          delete_os_disk_on_deletion = true
        }
        key_vault {
          recover_soft_deleted_key_vaults = true
          purge_soft_delete_on_destroy    = true
        }
      }
    }

    provider "azurerm" {
      features {}
      alias           = "vrecore"
      subscription_id = "${get_env("ARM_SUBSCRIPTION_ID")}"
    }

    provider "aws" {
      region = "eu-central-1"
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
        azuread = {
          source  = "hashicorp/azuread"
          version = "~> ${local.vars.versions.azuread}"
        }
        aws = {
          source = "hashicorp/aws"
          version = "~> ${local.vars.versions.aws}"
        }
        random = {
          source  = "hashicorp/random"
          version = "~> ${local.vars.versions.random}"
        }
        tls = {
          source  = "hashicorp/tls"
          version = "~> ${local.vars.versions.tls}"
        }
        ansible = {
          source  = "nbering/ansible"
          version = "~> ${local.vars.versions.ansible}"
        }
      }
    }
  EOF
}

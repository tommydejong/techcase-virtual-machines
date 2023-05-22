# VRE Storage Module Change Log

## v1.2.0

- The storage container for applied VRE configs is not created by this module anymore. This is because of problems with the Azure API and Terraform `azurerm` provider. See the comments in `azure-storage-account.tf`
- Change default firewall rules for storage account. There are default rules for the GitLab runner and eduVPN range.
- Default action is set to Allow, for the same reason as mentioned in bullet 1. This is needed to perform the required operations. Default action is set to Deny by the helper script `upload_vre_config_blob_v2.sh` in a Terragrunt `after_apply` hook.
- Move Azure File Share block (`azure-file-share.tf`) to the Azure module due to same firewall issues.

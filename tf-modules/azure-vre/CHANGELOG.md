# Azure VRE Change Log

## v1.2.0

- The key vault is now split in a management key vault (mgmt-kv) and the regular key vault (kv). The VRE only has access to the regular KV. Any secrets that should not be readable inside the VRE should be stored in the management key vault.
- The key vault's firewall default action is now set to Deny. Only our GitLab runner can access the vault by default. In the regular KV, also the VM's subnet has default access.
- The following secrets are no longer stored in the key vault. They are now only available in the state file: Jumpcloud API key, SSH key, VM password
- Changed the method for supplying the Jumpcloud API key and SSH key to the initialization script for Windows VRE's. The key is now passed directly using the `base64encode` function, instead of it being grabbed from the key vault.
- The `computername` (or hostname, which is the name of the device in Jumpcloud) is now concatenated from the values inside the `tags` array. It is a combination of `instance`+`faculty`+`project`. This implementation can be seen and changed in `locals.tf`.
- Fix license-server connectivity if selecting software 'spss' or 'maxqda2020'

## v1.1.3

- Since we replicated the SIG to both HvA and UvA tenants, we do not need a separate provider for the image anymore
- You can now also specify a custom VM size. If the value is not in the mapping list (`var.vmSizemapping`, see variables.tf), the module will try the provided value. This way you can use any VM size that is available from `az vm list-sizes --location "<region>"`

## v1.1.2

- Fixed JumpCloud not automatically provisioned when a key was provided on Linux

## v1.1.1

- Add HvA VPN ranges. This can now be enabled in the `vre-config.yml` using `allowHvaVPN = true`

## v1.1.0

- Added automount for ResearchDrive
- Fix Ansible groups so that a VRE without software can also be created
- Changes to some role assignments to make them work for both Windows and Linux

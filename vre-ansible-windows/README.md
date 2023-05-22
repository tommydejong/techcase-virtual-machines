# Ansible scripts Windows

This repository contains all Ansible scripts for deploying applications to
Windows VREs.

## Supported software packages

| name | version | notes |
| ------ | ------ | ------ |
| rstudio | 1.4.1717 | |
| maxqda2020 | 2040 | |
| qdaminer | 1.1 | |
| spss | 25 | Not working properly yet! |
| stata | v17-mp4-ab01 | |
| vlc | 3.0.16 | |
| mpc | 1.9.16 | |
| azurestorageexplorer | 1.22.0 | |

## Available plugins

**plugin-azfileshare** For automatically mounting an Azure File Share.
**plugin-researchdrive** For automatically mounting a ResearchDrive instance.

## How to add new packages

You can easily make new software packages available to the VRE. Simply add another directory (called `application-<name>` or `plugin-<name>`) and create your playbook there. Most of the times you can simply copy another one and make your changes to the tasks. Some things to note:
1. **Follow the naming convention** for the `hosts:` parameter in the playbook. The convention is `<software.name>_<software.version>`. These values correspond with the `software` block in the `vre-config.yml`. For example, when you set the `hosts:` parameter to `rstudio_1.4.1717`, you can use this package in the `vre-config.yml` by adding the following to the `software` block:
```
software:
  - name: "rstudio"
    version: "1.4.1717"
```
2. **Pin versions where possible.** For example with chocolatey, you can pin the software package version with the `--version` flag. If you want another version, just copy the part of the playbook and change the version. That way we can offer multiple versions to the VRE.
3. **IMPORTANT:** Add the package you created to the `main.yml` file. This file is used to import other playbooks. If you do not do this, Ansible will ignore the directory and not include your new playbook.

## Local testing

Put the packages you want to test in a `local/hosts.yml` file (dir `local` is
in `.gitignore`).

For example, a `local/hosts.yml` for testing SPSS:

```yaml
spss_25:
  hosts:
    host1:
      ansible_host: my-vre.westeurope.cloudapp.azure.com
      ansible_shell_type: powershell
```

Then run:

```bash
$ ansible-playbook -u vreadmin --private-key vre-admin.pem -i local/hosts.yml main.yml
```

_NB_ you'll probably have to supply some overrides for vars (e.g. in the example
the `sas_token)` using the `-e` option as well.

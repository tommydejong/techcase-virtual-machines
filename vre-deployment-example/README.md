# VRE instructions

[TOC]

## Prerequisites

- A SSH (such as Putty) or RDP (mstsc or the official Remote Desktop app by Microsoft) client

## Configure the VRE

To deploy a VRE, simply edit the [vre-config.yml](./vre-config.yml) file using the values you want.
You can do this within GitLab, or by cloning this repository. You should not have to edit any other of the files in this repository.

The config file is divided into five sections:

- **VRE details:** Here you can provide metadata that apply to the VRE. These values are written to tags that are appended to the VRE resources in the cloud.
- **VRE specifications:** Here you can configure hardware specifications of the VRE, and the software you want to install.
- **Storage options:** Here you can specify which types of storage should be added to the VRE. These are automatically mounted inside the VRE.
- **RDP Access rules:** In this section you can enable default rules and add your own. Be sure to replace the default `remoteAccessRules` with your own!
- **Additional custom firewall rules:** Here you can open specific ports on the VRE. Again, be sure to replace the default `firewallRules` with your own!

Note: the [vre-versions.yml](./vre-versions.yml) file is used to specify which versions of the Terraform providers, binaries and modules are used.
You should not have to edit this, just follow the versions that come with the example.

When you're done making changes, add a commit message that describes your changes and click the **Commit changes** button. Don't change the *Target branch*.

## Deploy the VRE

In the current GitLab project, go to CI/CD -> Pipelines in the menu on the left.

If the repository is newly created, you should only see a pipeline with a status
of *skipped*, with a commit message `[skip ci] Initial commit`. This means no
VRE has been deployed before.

If you just made changes to the `vre-config.yml` file, you should see a pipeline
that corresponds to your commit.

There will probably be a pipeline on top with status a status of pending,
running, or blocked. This pipeline is started automatically due to the
configuration changes made in the previous section.

If there is _no_ recent pipeline on top in the states mentioned, please press
the `Run pipeline` button in the upper right corner. In the next screen press
`Run pipeline` again. A new pipeline should appear.

Click the pipeline and wait for the status to turn green for
`Build -> plan`.

In the current pipeline with green status for `plan`, press the play-button
(Play all manual) right next to `Deploy`.

Wait for both `apply` (under Deploy) and `ansible` (under Configure) to turn
green.

Assuming the build was successful, proceed
to [Connect to the VRE](#connect-to-the-vre).

### Troubleshooting

In general, do _not_ reuse any previously failed pipelines! These will typically
reuse the configuration that broke in the first place.

##### pipeline apply or ansible fails

Click on the failing pipeline step and see if you can figure out something that
can be fixed in the configuration. If so, follow the steps in
section [remove the VRE](#remove-the-vre) before fixing the configuration. After
removing the (broken) VRE and reconfiguring,
redo [Deploy the VRE](#deploy-the-vre).

## Connect to the VRE

Go to your JumpCloud admin console and look up the new VRE under `Device Management -> Devices`.
Select the `Users` tab and add (select checkbox) the user you want to use.

__NB__ make sure you have a password for the user or add one by clicking on the
user and navigating to tab
`Details - > User Security Settings and Permissions`.

Make a note of the `remote IP address` of your new machine in the
`Details -> Network` tab.

Start your RDP/SSH client and connect to the remote IP address. You will be prompted your JC user
and password.

__NB__ You will get a certificate warning. This is a known issue. You can safely ignore this.

__NB__ When you have chosen to mount a ResearchDrive, it will be mounted on drive letter `R:` on Windows and on `/media/rdrive` on Linux.

Congratulations! You're ready to use the VRE!

### Troubleshooting

#### JumpCloud is not available

There is an admin user available on the VRE. Please contact a VRE technician for an alternative way to log in.

## Remove the VRE

You can remove the VRE itself while keeping the storage intact. To do this, run a pipeline under `CI/CD -> Pipelines`.
After clicking `Run Pipeline` you have the option to enter key=value variable pairs. To destroy the VRE, enter the following pair:
`NUKE_FROM_ORBIT = the only way to make sure`

Now, when you click `Run pipeline` to confirm, GitLab will run the `destroy` stage to delete your VRE resources.

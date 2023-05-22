packer {
  required_version = ">= 1.7.4"
  required_plugins {
    windows-update = {
      version = "0.14.0"
      source  = "github.com/rgl/windows-update"
    }
  }
}

# Create some formatted timestamps to use in the script
locals {
  timestamp       = regex_replace(timestamp(), "[- TZ:]", "")
  formatted_date  = formatdate("YYYY.MM.DD", timestamp())
  expiration_date = timeadd(timestamp(), "720h") # 30 days
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors onto a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/from-1.5/blocks/source
source "azure-arm" "windows-uva" {
  # Pass credentials using variables
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  location        = "${var.azureRegion}"

  # Provide the Azure source image specifications
  image_publisher = "${var.azureImagePublisher}"
  image_offer     = "${var.azureImageOffer}"
  image_sku       = "${var.azureImageSku}"

  # Write the new image to our Shared Image Gallery in the UvA subscription
  shared_image_gallery_destination {
    subscription        = "${var.subscription_id}"
    resource_group      = "packer-images-prod"
    gallery_name        = "packersig"
    image_name          = "${var.azureImagePublisher}_${var.azureImageOffer}_${var.azureImageSku}" # The image definition this image version should be added to
    image_version       = "${local.formatted_date}" # Use a formatted timestamp as the version number to be able to sort these images by latest
    replication_regions = ["westeurope", "northeurope"]
  }
  shared_gallery_image_version_end_of_life_date = "${local.expiration_date}"

  # Necessary block for the shared image gallery
  managed_image_name                = "${var.azureImagePublisher}_${var.azureImageOffer}_${var.azureImageSku}_${var.osType}_${local.timestamp}"
  managed_image_resource_group_name = "packer-images-prod"

  os_type         = "Windows"
  os_disk_size_gb = "${var.osDiskSize}"
  vm_size         = "${var.vmSize}"

  azure_tags = {
    os        = "${var.azureImagePublisher}"
    osOffer   = "${var.azureImageOffer}"
    osSku     = "${var.azureImageSku}"
    createdBy = "Packer"
    createdOn = "${local.timestamp}"
  }

  communicator   = "winrm"
  winrm_insecure = true
  winrm_timeout  = "15m"
  winrm_use_ssl  = true
  winrm_username = "packer"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  sources = [
    "source.azure-arm.windows-uva",
    ]

  provisioner "powershell" {
    scripts = [
      "installscripts/windows/1-security-patches.ps1",
      "installscripts/windows/2-install-chocolatey.ps1",
      "installscripts/windows/3-remove-defaultapps.ps1",
      "installscripts/windows/4-add-config-and-packages.ps1"
    ]
  }

  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
  }

  provisioner "windows-update" {
    search_criteria = "BrowseOnly=0 and IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 15
  }

  provisioner "powershell" {
   inline = [
        "  while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
        "  while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",

        "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
        "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
   ]
  }

  post-processor "manifest" {
    output     = "packer-manifest.json"
    strip_path = true
  }
}

packer {
  required_version = ">= 1.7.4"
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

# Source block for Azure Linux image
source "azure-arm" "azure-linux-uva" {
  # Pass credentials using variables
  subscription_id = "${var.uva_subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  location        = "${var.azureRegion}"

  # Provide the Azure source image specifications
  image_publisher = "${var.azureImagePublisher}"
  image_offer     = "${var.azureImageOffer}"
  image_sku       = "${var.azureImageSku}"

  # Write the new image to our Shared Image Gallery in the UvA subscription
  shared_image_gallery_destination {
    subscription        = "02cbfa4d-0021-42a2-b9b7-9e99f40c27c7"
    resource_group      = "packer-images-prod"
    gallery_name        = "vrepackersig"
    image_name          = "${var.azureImagePublisher}_${var.azureImageOffer}_${var.azureImageSku}" # The image definition this image version should be added to
    image_version       = "${local.formatted_date}" # Use a formatted timestamp as the version number to be able to sort these images by latest
    replication_regions = ["westeurope", "northeurope"]
  }
  shared_gallery_image_version_end_of_life_date = "${local.expiration_date}"

  # Necessary block for the shared image gallery
  managed_image_name                = "${var.azureImagePublisher}_${var.azureImageOffer}_${var.azureImageSku}_${var.osType}_${local.timestamp}"
  managed_image_resource_group_name = "packer-images-prod"

  # Run all post-processing steps using SSH
  communicator = "ssh"

  # The specifications of the VM Packer should create to build the image
  # Should be heavy enough to avoid timeouts
  os_type         = "Linux"
  os_disk_size_gb = "${var.osDiskSize}"
  vm_size         = "${var.vmSize}"

  # Some metadata and tags for the image
  azure_tags = {
    os        = "${var.azureImagePublisher}"
    osOffer   = "${var.azureImageOffer}"
    osSku     = "${var.azureImageSku}"
    createdBy = "Packer"
    createdOn = "${local.timestamp}"
  }
}

# Exact copy of the block above for replicating to HvA tenant Shared Image Gallery. See Jira ticket RITB-612
source "azure-arm" "azure-linux-hva" {
  # Pass credentials using variables
  subscription_id = "${var.hva_subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  location        = "${var.azureRegion}"

  # Provide the Azure source image specifications
  image_publisher = "${var.azureImagePublisher}"
  image_offer     = "${var.azureImageOffer}"
  image_sku       = "${var.azureImageSku}"

  # Write the new image to our Shared Image Gallery in the UvA subscription
  shared_image_gallery_destination {
    subscription        = "bda6d3ef-315d-4f01-9b99-b692a21383ff"
    resource_group      = "packer-images-prod"
    gallery_name        = "vrepackersig"
    image_name          = "${var.azureImagePublisher}_${var.azureImageOffer}_${var.azureImageSku}" # The image definition this image version should be added to
    image_version       = "${local.formatted_date}" # Use a formatted timestamp as the version number to be able to sort these images by latest
    replication_regions = ["westeurope", "northeurope"]
  }
  shared_gallery_image_version_end_of_life_date = "${local.expiration_date}"

  # Necessary block for the shared image gallery
  managed_image_name                = "${var.azureImagePublisher}_${var.azureImageOffer}_${var.azureImageSku}_${var.osType}_${local.timestamp}"
  managed_image_resource_group_name = "packer-images-prod"

  # Run all post-processing steps using SSH
  communicator = "ssh"

  # The specifications of the VM Packer should create to build the image
  # Should be heavy enough to avoid timeouts
  os_type         = "Linux"
  os_disk_size_gb = "${var.osDiskSize}"
  vm_size         = "${var.vmSize}"

  # Some metadata and tags for the image
  azure_tags = {
    os        = "${var.azureImagePublisher}"
    osOffer   = "${var.azureImageOffer}"
    osSku     = "${var.azureImageSku}"
    createdBy = "Packer"
    createdOn = "${local.timestamp}"
  }
}

# Source block for AWS Linux image
source "amazon-ebs" "aws-linux" {
  region = var.awsRegion
  
  # Find the latest source AMI
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "*${var.awsImagePublisher}*-${var.awsImageOffer}*-${var.awsImageSku}*-amd64-server-*"
      root-device-type    = "ebs"
    }
    owners = ["099720109477"] # Canonical account number
    most_recent = true
  }

  # The specifications of the VM Packer should create to build the image
  # Should be heavy enough to avoid timeouts
  instance_type = var.ec2Size
  ssh_username  = "ubuntu" # This is the default username for Canonical base images
  
  # The name of the new image that Packer should output. Append a formatted timestamp to be able to sort these images by latest
  ami_name = "${var.awsImagePublisher}_${var.awsImageOffer}_${var.awsImageSku}_${var.osType}_${local.timestamp}"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  # Build a Linux image for both Azure and AWS
  sources = [
    "source.azure-arm.azure-linux-uva",
    "source.azure-arm.azure-linux-hva",
    "source.amazon-ebs.aws-linux"
  ]

  # Run apt update & upgrade using the shell provisioner
  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive", # To prevent warnings
      "/usr/bin/cloud-init status --wait", # Wait for cloud init to prevent apt errors
      "sudo apt-get update",
      "sudo apt-get upgrade -y"
    ]
  }

  # Run shell scripts
  provisioner "shell" {
    scripts = [
      "installscripts/linux/1-security-patches.sh",
      "installscripts/linux/2-add-config-and-packages.sh"
    ]
  }

  # ...Add additional post-processing steps here...

  # Output the Packer manifest for a pipeline artifact
  post-processor "manifest" {
    output     = "packer-manifest.json"
    strip_path = true
  }
}

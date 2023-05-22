locals {
  linux           = var.osType == "linux" ? { dummy_create = true } : {}
  windows         = var.osType == "windows" ? { dummy_create = true } : {}
  sharedImageName = var.osType == "windows" ? "MicrosoftWindowsDesktop_office-365_21h1-evd-o365pp" : "Canonical_0001-com-ubuntu-server-focal_20_04-lts"
  instance        = lookup(var.tags, "instance")
  faculty         = lookup(var.tags, "faculty")
  project         = lookup(var.tags, "project")
  computerName    = lower(replace(join(",", ["${local.instance}", "${local.faculty}", "${local.project}"]), ",", ""))
  adminUsername   = "vreadmin"
  vmSize          = contains(keys(var.vmSizeMapping), var.vmSize) ? lookup(var.vmSizeMapping, var.vmSize) : var.vmSize

  software_list = [for s in var.software : "${s.name}_${s.version}"]
  shell_type    = var.osType == "windows" ? "powershell" : "sh"

  needs_lic_server    = ["maxqda2020", "spss"]
  requires_trusted_ip = setintersection([for s in var.software : s.name], local.needs_lic_server) != []
}

locals {
  # Inputs
  vreconfig = yamldecode(file("vre-config.yml"))
  versions = yamldecode(file("vre-versions.yml"))

  # Common labels
  projectName = "${local.vreconfig.faculty}-${local.vreconfig.project}"
  workspaceName = "${local.projectName}-workspace"
  trimmed_workspaceName = replace(local.workspaceName, "-", "")

  # Common tags
  tags = merge(local.vreconfig.additionalTags,
    {
      "costCenter"   = local.vreconfig.costCenter
      "createdBy"    = "terraform"
      "service"      = "VRE"
      "instance"     = "rs"
      "faculty"      = local.vreconfig.faculty
      "project"      = local.vreconfig.project
      "projectOwner" = local.vreconfig.projectOwner
      "supportLevel" = local.vreconfig.supportLevel
      "osType"       = local.vreconfig.osType
    }
  )
}
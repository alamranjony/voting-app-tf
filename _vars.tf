# variable "ado_org_service_url" {
#   type        = string
#   description = "Org service url for Azure DevOps"
#   default     = "https://dev.azure.com/living-turf/"
# }

# variable "ado_pat" {
#   type        = string
#   description = "Personal authentication token for Azure DevOps Organization"
#   sensitive   = true
# }


# Local variables

locals {
  project   = "robotshop"
  env       = terraform.workspace
  region    = "asse"
  location  = "Southeast Asia"

  publisher_name  = "nanotech"
  publisher_email = "amran@nanotech.cloudns.asia"

  env_code_branches = {
    "dev"  = "develop",
    "uat"  = "uat",
    "prod" = "main"
  }

  config_env_names = {
    "dev"  = "Development"
    "uat"  = "Uat"
    "prod" = "Production"
  }

  env_code_branch = local.env_code_branches[local.env]
  config_env_name = local.config_env_names[local.env]

  storage_account_name = "robotshopsta01"

  service_plan_name    = "asp-${local.project}-${local.env}-${local.region}-001"
  logaw_name           = "log-${local.project}-${local.env}-${local.region}-001"
}
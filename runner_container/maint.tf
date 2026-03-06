# --- Provider & Variables ---
provider "azurerm" {
  features {}
}

variable "location"           { default = "East US" }
variable "resource_group_name" { default = "rg-gh-runners" }
variable "runner_count"        { default = 5 }
variable "github_repo_url"     {default="https://github.com/DataAIShift/gh-pocs"} # Pass via TF_VAR_github_repo_url

variable "github_token" {
  type        = string
  description = "Registration token for the GitHub runner"
  sensitive   = true
}






# 1. Reference your existing ACR
data "azurerm_container_registry" "acr" {
  name                = "containerRegistryPratik1" 
  resource_group_name = "az-rc-docai-rg-pratik"
}

# 2. Reference your existing Managed Identity
data "azurerm_user_assigned_identity" "runner_id" {
  name                = "ai-access-pratik"
  resource_group_name = "az-rc-docai-rg-pratik"
}

# 3. Ensure the Identity has AcrPull permissions
# Even if already assigned, keeping this in TF ensures it doesn't break
resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_user_assigned_identity.runner_id.principal_id
}

# 4. The Container Group Configuration
resource "azurerm_container_group" "runners" {
  count               = var.runner_count
  name                = "aci-gh-runner-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "None"
  os_type             = "Linux"
  restart_policy      = "Always"

  # Attach the existing identity
  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.runner_id.id]
  }

  # Tell ACI to use this identity to authenticate with the registry

  container {
    name   = "runner"
    image  = "${data.azurerm_container_registry.acr.login_server}/gh-runner:latest"
    cpu    = "2.0"
    memory = "4.0"

    environment_variables = {
      REPO_URL        = var.github_repo_url
      RUNNER_NAME     = "aci-runner-${count.index}"
      RUNNER_LABELS   = "azure-aci,ubuntu-latest"
      # Using the client_id from the data source
      AZURE_CLIENT_ID = data.azurerm_user_assigned_identity.runner_id.client_id
    }

    secure_environment_variables = {
      RUNNER_TOKEN = var.github_token
    }

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  image_registry_credential {
    # Only the server is needed when image_registry_identity is set
    server = data.azurerm_container_registry.acr.login_server
  }

  # Good practice to wait for role assignment propagation
  depends_on = [azurerm_role_assignment.acr_pull]
}
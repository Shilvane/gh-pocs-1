variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be created"
  default = "northeurope"
}

# --- VM Configuration ---

variable "vm_name" {
  type        = string
  description = "The name of the Virtual Machine"
  default = "Github-Runner-Dev"
}

variable "vm_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "The size of the Azure Virtual Machine"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
  default = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM access"
  sensitive   = true
}

variable "ubuntu_os_version" {
  type        = string
  default     = "22_04-lts-gen2"
  description = "The Ubuntu OS version to use"
}

# --- Networking ---

variable "vnet_name" {
  type        = string
  description = "The name of the Virtual Network"
  default = "AZ-AS-AVN-VN-N-SEQ02006-pratik"
}

variable "subnet_name" {
  type        = string
  description = "The name of the Subnet"
  default="AZ-AS-AVN-SN-N-SEQ02006-pratik"
}

variable "vnet_resource_group" {
  type        = string
  description = "The resource group where the VNet is located"
  default = "ai-project-staterg"
}

# --- GitHub Runner Configuration ---

variable "github_runner_token" {
  type        = string
  description = "Registration token for the GitHub runner"
  sensitive   = true
}

variable "github_repo_url" {
  type        = string
  description = "The full URL of the GitHub repository"
  default = "https://github.com/DataAIShift/gh-pocs"
}

variable "runner_name" {
  type        = string
  description = "Name of the self-hosted runner"
  default = "iac-ghu-runner"
}

variable "runner_labels" {
  type        = string
  description = "Comma-separated labels for the runner"
  default = "self-hosted,Linux,X64,dev,citrix,Github-Runner-Dev"
}

# --- Metadata ---

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}
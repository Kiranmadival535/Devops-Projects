variable "rgname" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
  default     = "centralindia"
}

variable "service_principal_name" {
  type        = string
  description = "Name for the service principal"
}

variable "keyvault_name" {
  type        = string
  description = "Key Vault name"
}

variable "SUB_ID" {
  type        = string
  description = "Azure Subscription ID"
}

variable "node_pool_name" {
  type        = string
  description = "AKS node pool name"
}

variable "cluster_name" {
  type        = string
  description = "AKS cluster name"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key data for Linux VMs in AKS"
}

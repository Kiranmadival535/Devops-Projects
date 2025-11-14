variable "location" {

}
 variable "resource_group_name" {}

variable "service_principal_name" {
  type = string
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key data for Linux nodes in AKS"
}


variable "client_id" {}
variable "client_secret" {
  type = string
  sensitive = true
}

variable "node_pool_name" {
  
}
variable "cluster_name" {
  
}

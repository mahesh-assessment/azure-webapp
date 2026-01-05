# variables.tf
variable "location" {
  default = "Central India"
}

variable "resource_group_name" {
  default = "rg-quote-app"
}

variable "vnet_cidr" {
  default = "10.10.0.0/16"
}

# Add this variable
variable "create_local_key_vault" {
  description = "Create a local Key Vault copy for AKS to access secrets"
  type        = bool
  default     = false
}


# variables.tf - Add HA-specific variables
variable "ha_enabled" {
  description = "Enable high availability features"
  type        = bool
  default     = true
}

variable "aks_node_count" {
  description = "Number of AKS nodes for HA"
  type        = number
  default     = 3
}

variable "agw_min_capacity" {
  description = "Minimum AGW capacity for HA"
  type        = number
  default     = 2
}

variable "agw_max_capacity" {
  description = "Maximum AGW capacity for auto-scaling"
  type        = number
  default     = 10
}

variable "base_name" {
  type        = string
  description = "Base name for the Foundry account and derived resources."
  validation {
    condition     = length(var.base_name) >= 3 && length(var.base_name) <= 20
    error_message = "base_name must be 3-20 characters."
  }
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "resource_group_name" {
  type = string
}

variable "disable_local_auth" {
  type        = bool
  default     = true
  description = "Entra-only auth. Keep true; local keys are a standing credential risk."
}

variable "public_network_enabled" {
  type        = bool
  default     = true
  description = "Enabled for personal showcase; false + private endpoints for work/GCC."
}

variable "model_deployments" {
  type = list(object({
    name     = string
    format   = string
    version  = string
    sku_name = string
    capacity = number
  }))
  default = []
}

variable "log_retention_days" {
  type    = number
  default = 31
}

variable "tags" {
  type = map(string)
  default = {
    managedBy = "formwork"
    standard  = "architects-cornerstone"
  }
}

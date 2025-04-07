############################
# Firewall variables
############################
variable "hub_location" {
  description = "Location for hub resources"
  type        = string
}

variable "firewall_subnet_id" {
  description = "Azure Firewall Subnet for AzureFirewall resource"
  type        = string
}

variable "hub_resource_group" {
  description = "Hub resource group"
  type        = string
}
variable "firewall_zones" {
  description = "Firewall Availability Zones"
  type        = list(string)
}
variable "firewall_pip_name" {
  description = "Firewall Public IP name"
  type        = string
}
variable "firewall_pip_allocation_method" {
  description = "Firewall Public IP allocation_method"
  type        = string
}
variable "firewall_pip_sku" {
  description = "Firewall Public IP sku"
  type        = string
}
variable "firewall_name" {
  description = "Firewall Name"
  type        = string
}
variable "firewall_policy_name" {
  description = "Firewall Policy name"
  type        = string
}
variable "firewall_sku_tier" {
  description = "Firewall SKU tier Standard/Premium"
  type        = string
  default     = "Standard"
}

variable "firewall_tags" {
  description = "Tags for Azure Firewall"
  type        = map(string)
}

variable "firewall_dnat_rule_collections" {
  description = "List of firewall DNAT rules"
  type = map(object({
    action = string
    rules = list(object({
      name                = string
      description         = optional(string)
      source_addresses    = list(string)
      destination_ports   = list(string)
      destination_address = string
      translated_port     = string
      translated_address  = string
      protocols           = list(string)
    }))
  }))
  default = {}
}
variable "firewall_network_rule_collections" {
  description = "Map of firewall network rule collections, where keys are collection names and values are lists of rules."
  type = map(object({
    action = string
    rules = list(object({
      name                  = string
      source_addresses      = list(string)
      destination_ports     = list(string)
      destination_addresses = list(string)
      protocols             = list(string)
    }))
  }))
}
variable "firewall_app_rule_collections" {
  description = "Map of firewall application rule collections, where keys are collection names and values are lists of rules."
  type = map(object({
    action = string
    rules = list(object({
      name              = string
      source_addresses  = list(string)
      destination_fqdns = list(string)
      protocols = list(object({
        port = string
        type = string
      }))
    }))
  }))
  default = {}
}

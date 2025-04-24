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

variable "firewall_policy_rule_collection_groups" {
  description = "Map of firewall policy rule collection groups. Keys are the names of the rule collection groups."
  type = map(object({
    priority = number

    firewall_app_rule_collections = optional(map(object({
      action = string
      rules = list(object({
        name                  = string
        source_addresses      = list(string)
        destination_fqdns     = optional(list(string))
        destination_fqdn_tags = optional(list(string)) # For FQDN tags
        destination_addresses = optional(list(string)) # For application tags
        web_categories        = optional(list(string))
        protocols = list(object({
          port = string
          type = string
        }))
      }))
    })), {})

    firewall_network_rule_collections = optional(map(object({
      action = string
      rules = list(object({
        name                  = string
        source_addresses      = list(string)
        destination_ports     = list(string)
        destination_addresses = optional(list(string)) # Mixed values: IP ranges or service tags
        destination_ip_groups = optional(list(string)) # List of IP Group resource IDs
        destination_fqdns     = optional(list(string)) # List of FQDNs
        protocols             = list(string)
      }))
    })), {})

    firewall_dnat_rule_collections = optional(map(object({
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
    })), {})

  }))
}

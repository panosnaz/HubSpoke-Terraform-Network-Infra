terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.26.0"
    }
  }
}

# Azure Firewall - Public IP
#################################
resource "azurerm_public_ip" "hub_firewall_pip" {
  name                = var.firewall_pip_name
  location            = var.hub_location
  resource_group_name = var.hub_resource_group

  allocation_method = var.firewall_pip_allocation_method
  sku               = var.firewall_pip_sku
  zones             = var.firewall_zones
}

# Azure Firewall Policy
#################################
resource "azurerm_firewall_policy" "azure_firewall_policy" {
  name                = var.firewall_policy_name
  resource_group_name = var.hub_resource_group
  location            = var.hub_location

  dns {
    proxy_enabled = true
  }
  # intrusion_detection {
  #   mode = "Alert"
  # }
  # tls_certificate {
  #     key_vault_secret_id = azurerm_key_vault_secret.Certificate.id//<id of the keyvault Secret where CA is stored>
  #     name = //<name of the certificate stored in the keyvault>
  # }
  tags = var.firewall_tags
}

# Azure Firewall
#################################
resource "azurerm_firewall" "azure_firewall" {
  name                = var.firewall_name
  location            = var.hub_location
  resource_group_name = var.hub_resource_group
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku_tier
  zones               = var.firewall_zones
  firewall_policy_id  = azurerm_firewall_policy.azure_firewall_policy.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.hub_firewall_pip.id
  }

  tags = var.firewall_tags
}

########################################
# Firewall Policy Rule Collection Groups
########################################
resource "azurerm_firewall_policy_rule_collection_group" "firewall_policy_rule_collection_group" {
  for_each           = var.firewall_policy_rule_collection_groups
  name               = each.key
  firewall_policy_id = azurerm_firewall_policy.azure_firewall_policy.id
  priority           = each.value.priority

  ###################
  # Application Rules
  ###################
  dynamic "application_rule_collection" {
    for_each = each.value.firewall_app_rule_collections != null ? each.value.firewall_app_rule_collections : {}
    content {
      name     = application_rule_collection.key                                                              # Collection name 
      priority = 200 + index(keys(each.value.firewall_app_rule_collections), application_rule_collection.key) # Unique priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name             = rule.value.name
          source_addresses = rule.value.source_addresses
          # destination_fqdns = rule.value.destination_fqdns

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              port = protocols.value.port
              type = protocols.value.type
            }
          }
          # Support destination_fqdns or destination_addresses (for application tags)
          destination_fqdns     = contains(keys(rule.value), "destination_fqdns") ? rule.value.destination_fqdns : null
          destination_fqdn_tags = contains(keys(rule.value), "destination_fqdn_tags") ? rule.value.destination_fqdn_tags : null
          destination_addresses = contains(keys(rule.value), "destination_addresses") ? rule.value.destination_addresses : null
          web_categories        = contains(keys(rule.value), "web_categories") ? rule.value.web_categories : null
        }
      }
    }
  }

  ###################
  # Network Rules
  ###################
  dynamic "network_rule_collection" {
    for_each = each.value.firewall_network_rule_collections != null ? each.value.firewall_network_rule_collections : {}
    content {
      name     = network_rule_collection.key                                                                  # Collection name 
      priority = 100 + index(keys(each.value.firewall_network_rule_collections), network_rule_collection.key) # Unique priority
      action   = network_rule_collection.value.action                                                         # Default action at the collection level

      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name              = rule.value.name
          source_addresses  = rule.value.source_addresses
          destination_ports = rule.value.destination_ports
          protocols         = rule.value.protocols

          destination_addresses = contains(keys(rule.value), "destination_addresses") && rule.value.destination_addresses != null ? rule.value.destination_addresses : null
          destination_ip_groups = contains(keys(rule.value), "destination_ip_groups") && rule.value.destination_ip_groups != null ? rule.value.destination_ip_groups : null
          destination_fqdns     = contains(keys(rule.value), "destination_fqdns") && rule.value.destination_fqdns != null ? rule.value.destination_fqdns : null
        }
      }
    }
  }

  ###################
  # DNAT Rules
  ###################
  dynamic "nat_rule_collection" {
    for_each = {
      for k, v in lookup(each.value, "firewall_dnat_rule_collections", {}) : k => v if length(v) > 0
    }

    content {
      name     = nat_rule_collection.key
      priority = 300 + index(keys(lookup(each.value, "firewall_dnat_rule_collections", {})), nat_rule_collection.key)
      action   = nat_rule_collection.value.action

      dynamic "rule" {
        for_each = nat_rule_collection.value.rules
        content {
          name                = rule.value.name
          source_addresses    = rule.value.source_addresses
          destination_ports   = rule.value.destination_ports
          destination_address = rule.value.destination_address
          translated_port     = rule.value.translated_port
          translated_address  = rule.value.translated_address
          protocols           = rule.value.protocols
        }
      }
    }
  }
  depends_on = [azurerm_firewall_policy.azure_firewall_policy]
}


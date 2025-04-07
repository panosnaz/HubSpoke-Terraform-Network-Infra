terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.23.0"
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

  # dns_proxy_enabled = true


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
  name               = "fw-policy-rcg"
  firewall_policy_id = azurerm_firewall_policy.azure_firewall_policy.id
  priority           = 100

  ###################
  # Application Rules
  ###################
  dynamic "application_rule_collection" {
    for_each = var.firewall_app_rule_collections != null ? { for k, v in var.firewall_app_rule_collections : k => v if length(v) > 0 } : {}
    content {
      name     = application_rule_collection.key                                                       # Collection name 
      priority = 200 + index(keys(var.firewall_app_rule_collections), application_rule_collection.key) # Unique priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name              = rule.value.name
          source_addresses  = rule.value.source_addresses
          destination_fqdns = rule.value.destination_fqdns

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              port = protocols.value.port
              type = protocols.value.type
            }
          }
        }
      }
    }
  }

  ###################
  # Network Rules
  ###################
  dynamic "network_rule_collection" {
    for_each = { for k, v in var.firewall_network_rule_collections : k => v if length(v) > 0 }
    content {
      name     = network_rule_collection.key                                                           # Collection name 
      priority = 100 + index(keys(var.firewall_network_rule_collections), network_rule_collection.key) # Unique priority
      action   = network_rule_collection.value.action                                                  # Default action at the collection level

      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name                  = rule.value.name
          source_addresses      = rule.value.source_addresses
          destination_ports     = rule.value.destination_ports
          destination_addresses = rule.value.destination_addresses
          protocols             = rule.value.protocols
        }
      }
    }
  }

  ###################
  # DNAT Rules
  ###################
  dynamic "nat_rule_collection" {
    for_each = var.firewall_dnat_rule_collections != null ? { for k, v in var.firewall_dnat_rule_collections : k => v if length(v) > 0 } : {}
    content {
      name     = nat_rule_collection.key                                                        # Collection name 
      priority = 300 + index(keys(var.firewall_dnat_rule_collections), nat_rule_collection.key) # Unique priority
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


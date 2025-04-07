terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">=4.23.0"
      configuration_aliases = [azurerm.spoke, azurerm.connectivity]
    }
  }
}

# Resource group for this Spokes's Vnets
resource "azurerm_resource_group" "spoke_vnet_rg" {
  provider = azurerm.spoke

  name     = var.spoke_resource_group
  location = var.spoke_location
}

# Spoke Vnet
resource "azurerm_virtual_network" "spoke_vnet" {
  depends_on = [azurerm_resource_group.spoke_vnet_rg]
  provider   = azurerm.spoke

  name                = var.spoke_vnet_name
  location            = azurerm_resource_group.spoke_vnet_rg.location
  resource_group_name = azurerm_resource_group.spoke_vnet_rg.name
  address_space       = [var.spoke_vnet_cidr]
  tags                = var.spoke_tags
  dns_servers         = var.dns_servers
}

# Spoke to Hub peering
resource "azurerm_virtual_network_peering" "spoke_hub_peer" {
  depends_on = [azurerm_virtual_network.spoke_vnet]
  provider   = azurerm.spoke

  name                      = "${var.spoke_vnet_name}-peer-${var.hub_vnet_name}"
  resource_group_name       = azurerm_resource_group.spoke_vnet_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = var.hub_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.peer_gateway_transit
  use_remote_gateways          = var.peer_remote_gw
}

# Hub to Spoke peering
resource "azurerm_virtual_network_peering" "hub_spoke_peer" {
  depends_on = [azurerm_virtual_network.spoke_vnet]
  provider   = azurerm.connectivity

  name                         = "${var.hub_vnet_name}-peer-${var.spoke_vnet_name}"
  resource_group_name          = var.hub_resource_group
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

# NSGs for every subnet in this Spoke
resource "azurerm_network_security_group" "spoke_nsg" {
  depends_on = [azurerm_resource_group.spoke_vnet_rg]
  provider   = azurerm.spoke

  # for_each = var.spoke_vnet_subnets

  # Apply only to regular subnets, excluding APIM subnets
  for_each = {
    for k, v in var.spoke_vnet_subnets : k => v
    # if !contains(var.api_management_subnets, v["name"]) # Exclude APIM subnets
  }

  name                = each.value["nsg_name"]
  location            = azurerm_resource_group.spoke_vnet_rg.location
  resource_group_name = azurerm_resource_group.spoke_vnet_rg.name
}
# resource "azurerm_network_security_group" "spoke_apim_nsg" {
#   depends_on = [azurerm_resource_group.spoke_vnet_rg]
#   provider   = azurerm.spoke

#   for_each = {
#     for k, v in var.spoke_vnet_subnets : k => v
#     if contains(var.api_management_subnets, v["name"]) # Filter only APIM subnets
#   }

#   name                = each.value["nsg_name"]
#   location            = azurerm_resource_group.spoke_vnet_rg.location
#   resource_group_name = azurerm_resource_group.spoke_vnet_rg.name
# }


# Spoke Subnets
resource "azurerm_subnet" "spoke_subnet" {
  depends_on = [azurerm_virtual_network.spoke_vnet]
  provider   = azurerm.spoke

  for_each                          = var.spoke_vnet_subnets
  name                              = each.value["name"]
  address_prefixes                  = [each.value["address_prefixes"]]
  virtual_network_name              = azurerm_virtual_network.spoke_vnet.name
  resource_group_name               = azurerm_resource_group.spoke_vnet_rg.name
  private_endpoint_network_policies = each.value.private_endpoint_network_policies

  service_endpoints = each.value.service_endpoints
  dynamic "delegation" {
    for_each = each.value.service_delegation
    content {
      name = "delegation"
      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
}


# NSGs with Subnets associations (except for API MGMT subnets)
resource "azurerm_subnet_network_security_group_association" "spoke_nsg_associations" {
  depends_on = [
    azurerm_subnet.spoke_subnet,
    azurerm_network_security_group.spoke_nsg
  ]
  provider = azurerm.spoke

  for_each = {
    for k, v in var.spoke_vnet_subnets : k => v
    # if lookup(v, "nsg_name", "") != "" && !(contains(var.api_management_subnets, k))
  }
  subnet_id                 = azurerm_subnet.spoke_subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.spoke_nsg[each.key].id
}

# Route table for this Spoke Vnet
resource "azurerm_route_table" "spoke_udr" {
  depends_on = [azurerm_resource_group.spoke_vnet_rg]
  provider   = azurerm.spoke

  name                          = var.spoke_udr_name
  location                      = azurerm_resource_group.spoke_vnet_rg.location
  resource_group_name           = azurerm_resource_group.spoke_vnet_rg.name
  bgp_route_propagation_enabled = false
}
# Route table for Spoke subnets 'api management'
# resource "azurerm_route_table" "api_management_spoke_udr" {
#   depends_on = [azurerm_resource_group.spoke_vnet_rg]
#   provider   = azurerm.spoke

#   name                          = var.api_management_spoke_udr_name
#   location                      = azurerm_resource_group.spoke_vnet_rg.location
#   resource_group_name           = azurerm_resource_group.spoke_vnet_rg.name
#   bgp_route_propagation_enabled = false
# }


# UDR routes traffic forcing to Firewall this Spoke Vnet
resource "azurerm_route" "spoke_udr_routes" {
  depends_on = [azurerm_route_table.spoke_udr]
  provider   = azurerm.spoke

  for_each               = var.spoke_udr_routes
  name                   = each.value["name"]
  resource_group_name    = azurerm_resource_group.spoke_vnet_rg.name
  route_table_name       = azurerm_route_table.spoke_udr.name
  address_prefix         = each.value["address_prefix"]
  next_hop_type          = each.value["next_hop_type"]
  next_hop_in_ip_address = each.value["next_hop_in_ip_address"]
}
# resource "azurerm_route" "api_management_udr_routes" {
#   depends_on = [azurerm_route_table.api_management_spoke_udr]
#   provider   = azurerm.spoke

#   # Loop through the api_management_udr_routes variable
#   for_each               = var.api_management_udr_routes
#   name                   = each.value["name"]
#   resource_group_name    = azurerm_resource_group.spoke_vnet_rg.name
#   route_table_name       = azurerm_route_table.api_management_spoke_udr.name
#   address_prefix         = each.value["address_prefix"]
#   next_hop_type          = each.value["next_hop_type"]
#   next_hop_in_ip_address = each.value["next_hop_in_ip_address"]
# }


# Route table association for every subnet (except from API MGMT subnets) in Spoke
resource "azurerm_subnet_route_table_association" "udr_association" {
  depends_on = [
    azurerm_subnet.spoke_subnet,
    azurerm_route_table.spoke_udr
  ]
  provider = azurerm.spoke

  for_each = {
    for k, v in var.spoke_vnet_subnets : k => v
    # if !(contains(var.api_management_subnets, k))
  }

  subnet_id      = azurerm_subnet.spoke_subnet[each.key].id
  route_table_id = azurerm_route_table.spoke_udr.id
}


# Route table association for Spoke API subnets that need different Route tables than the rest Spokes
# resource "azurerm_subnet_route_table_association" "api_management_udr_association" {
#   depends_on = [
#     azurerm_subnet.spoke_subnet,
#     azurerm_route_table.api_management_spoke_udr
#   ]
#   provider = azurerm.spoke

#   # Associate only API subnets with a different route table
#   for_each = {
#     for k, v in var.spoke_vnet_subnets : k => v
#     if contains(var.api_management_subnets, k)
#   }

#   subnet_id      = azurerm_subnet.spoke_subnet[each.key].id
#   route_table_id = azurerm_route_table.api_management_spoke_udr.id
# }








#############


# resource "azurerm_subnet_network_security_group_association" "spoke_apim_nsg_associations" {
#   depends_on = [
#     azurerm_subnet.spoke_subnet,
#     azurerm_network_security_group.spoke_apim_nsg
#   ]
#   provider = azurerm.spoke

#   for_each = {
#     for k, v in var.spoke_vnet_subnets : k => v
#     if contains(var.api_management_subnets, k)
#   }
#   subnet_id                 = azurerm_subnet.spoke_subnet[each.key].id
#   network_security_group_id = azurerm_network_security_group.spoke_apim_nsg[each.key].id
# }

# # Combine NSGs and rules in a local variable
# locals {
#   apim_nsg_rule_combinations = flatten([
#     for nsg_name in var.api_management_nsg_name : [                  # Loop through each NSG name
#       for rule_key, rule in var.api_management_nsg_rules : {         # Loop through each NSG rule
#         nsg_name                   = nsg_name,                       # Store the NSG name
#         rule_key                   = rule_key,                       # Store the rule key
#         name                       = rule.name,                      # Store rule name
#         access                     = rule.access,                    # Store access type (Allow/Deny)
#         direction                  = rule.direction,                 # Store direction (Inbound/Outbound)
#         priority                   = rule.priority,                  # Store rule priority
#         protocol                   = rule.protocol,                  # Store protocol type
#         source_port_range          = rule.source_port_range,         # Store source port range
#         source_address_prefix      = rule.source_address_prefix,     # Store source address prefix
#         destination_port_ranges    = rule.destination_port_range,    # Store destination port range
#         destination_address_prefix = rule.destination_address_prefix # Store destination address prefix
#       }
#     ]
#   ])
# }
# resource "azurerm_network_security_rule" "apim_security_rules" {
#   depends_on = [
#     azurerm_subnet.spoke_subnet,
#     azurerm_network_security_group.spoke_apim_nsg
#   ]
#   provider = azurerm.spoke

#   resource_group_name         = azurerm_resource_group.spoke_vnet_rg.name
#   network_security_group_name = each.value.nsg_name

#   # Loop through each combination of NSG and rule
#   for_each = {
#     for i, combination in local.apim_nsg_rule_combinations : "${combination.nsg_name}-${combination.rule_key}" => combination
#   }

#   # Apply rule details
#   name                       = each.value.name                       # Set rule name
#   access                     = each.value.access                     # Set rule access type
#   direction                  = each.value.direction                  # Set rule direction
#   priority                   = each.value.priority                   # Set rule priority
#   protocol                   = each.value.protocol                   # Set rule protocol
#   source_port_range          = each.value.source_port_range          # Set source port range
#   source_address_prefix      = each.value.source_address_prefix      # Set source address prefix
#   destination_port_ranges    = each.value.destination_port_ranges    # Set destination port ranges
#   destination_address_prefix = each.value.destination_address_prefix # Set destination address prefix
# }


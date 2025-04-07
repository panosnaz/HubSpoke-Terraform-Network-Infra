terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.23.0"
    }
  }
}

# Hub Resource Group
resource "azurerm_resource_group" "hub_vnet_rg" {
  name     = var.hub_resource_group
  location = var.hub_location
}

# Hub Vnet
#################################
resource "azurerm_virtual_network" "hub_vnet" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name
  address_space       = [var.hub_vnet_cidr]
  tags                = var.hub_tags
  dns_servers         = var.dns_servers
}

# Firewall Subnet
#################################
resource "azurerm_subnet" "hub_firewall_subnet" {
  name                              = "AzureFirewallSubnet"
  resource_group_name               = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name              = azurerm_virtual_network.hub_vnet.name
  address_prefixes                  = [var.firewall_subnet]
  private_endpoint_network_policies = "Enabled"
}

# Gateway Subnet
resource "azurerm_subnet" "hub_gateway_subnet" {
  name                              = "GatewaySubnet"
  resource_group_name               = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name              = azurerm_virtual_network.hub_vnet.name
  address_prefixes                  = [var.gateway_subnet]
  private_endpoint_network_policies = "Enabled"
}

###########
# Bastion 
###########
resource "azurerm_subnet" "hub_bastion_subnet" {
  name                              = "AzureBastionSubnet"
  resource_group_name               = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name              = azurerm_virtual_network.hub_vnet.name
  address_prefixes                  = [var.bastion_subnet]
  private_endpoint_network_policies = "Enabled"
}
resource "azurerm_public_ip" "hub_bastion_ip" {
  name                = var.bastion_ip
  location            = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "hub_bastion_host" {
  name                = var.bastion_host
  location            = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.hub_bastion_ip.id
  }
}

#############
# HUB Subnets
#############

# NSGs for HUB Subnets
resource "azurerm_network_security_group" "hub_nsg" {
  depends_on = [azurerm_resource_group.hub_vnet_rg]
  #provider   = azurerm.connectivity

  for_each            = var.conn_vnet_subnets
  name                = each.value["nsg_name"]
  location            = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name
}
# NSGs with HUB Subnets associations
resource "azurerm_subnet_network_security_group_association" "hub_nsg_associations" {
  depends_on = [
    azurerm_subnet.conn_vnet_subnets,
    azurerm_network_security_group.hub_nsg
  ]
  #provider = azurerm.connectivity

  for_each                  = { for k, v in var.conn_vnet_subnets : k => v if lookup(v, "nsg_name", "") != "" }
  subnet_id                 = azurerm_subnet.conn_vnet_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.hub_nsg[each.key].id
}
# HUB Subnets
resource "azurerm_subnet" "conn_vnet_subnets" {
  depends_on = [azurerm_virtual_network.hub_vnet]
  # provider   = azurerm.connectivity

  for_each                          = var.conn_vnet_subnets
  name                              = each.value["name"]
  address_prefixes                  = [each.value["address_prefixes"]]
  virtual_network_name              = azurerm_virtual_network.hub_vnet.name
  resource_group_name               = azurerm_resource_group.hub_vnet_rg.name
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

#############
# VPN gateway
#############

# Route table for VPN gateway subnet
resource "azurerm_route_table" "vpn_gateway_route_table" {

  depends_on          = [azurerm_resource_group.hub_vnet_rg]
  name                = var.vpn_gateway_udr_name
  location            = var.hub_location
  resource_group_name = var.hub_resource_group
  tags                = var.vpn_gateway_tags


}
# VPN gateway subnet UDR routes to force VNET traffic over the Firewall instead of VNET peering
resource "azurerm_route" "vpn_gateway_udr_routes" {
  depends_on = [azurerm_route_table.vpn_gateway_route_table]

  for_each               = var.vpn_gateway_udr_routes
  name                   = each.value["name"]
  resource_group_name    = var.hub_resource_group
  route_table_name       = azurerm_route_table.vpn_gateway_route_table.name
  address_prefix         = each.value["address_prefix"]
  next_hop_type          = each.value["next_hop_type"]
  next_hop_in_ip_address = each.value["next_hop_in_ip_address"]
}

# Route table association for VPN Gateway subnet
resource "azurerm_subnet_route_table_association" "vgw-prod-hub-gwc-udr-association" {
  depends_on     = [azurerm_route_table.vpn_gateway_route_table]
  subnet_id      = azurerm_subnet.hub_gateway_subnet.id
  route_table_id = azurerm_route_table.vpn_gateway_route_table.id
}

# # Route table for this Spoke Vnet
# resource "azurerm_route_table" "gateway_udr" {
#   name                          = "${azurerm_subnet.hub_gateway_subnet.name}-udr"
#   location                      = azurerm_resource_group.hub_vnet_rg.location
#   resource_group_name           = azurerm_resource_group.hub_vnet_rg.name
#   disable_bgp_route_propagation = false
# }

# Route table association for Gateway subnet
# resource "azurerm_subnet_route_table_association" "gateway_udr_association" {
#   subnet_id      = azurerm_subnet.hub_gateway_subnet.id
#   route_table_id = azurerm_route_table.gateway_udr.id
# }

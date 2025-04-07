terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.23.0"
    }
  }
}

# Virtual Network Gateway - VPN Public IP
#################################
resource "azurerm_public_ip" "hub_vpn_gateway1_pip" {
  name                = var.vpn_gateway_pip_name
  location            = var.hub_location
  resource_group_name = var.hub_resource_group

  allocation_method = var.hub_vpn_gateway1_pip_allocation_method
  sku               = var.hub_vpn_gateway1_pip_sku
  zones             = var.hub_vpn_gateway1_pip_zones
}

# Virtual Network Gateway - VPN
#################################
resource "azurerm_virtual_network_gateway" "hub_vnet_gateway" {
  name                = var.vpn_gateway_name
  location            = var.hub_location
  resource_group_name = var.hub_resource_group

  type     = var.vpn_gateway_type
  vpn_type = var.vpn_gateway_vpn_type

  active_active = false
  enable_bgp    = false
  sku           = var.vpn_gateway_sku
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.hub_vpn_gateway1_pip.id
    private_ip_address_allocation = var.vpn_gateway_private_ip_address_allocation
    subnet_id                     = var.gateway_subnet_id
  }
  custom_route {
    address_prefixes = var.vpn_gateway_custom_route_address_prefixes
  }
  vpn_client_configuration {
    address_space = var.vpn_client_address_space

    # aad_audience         = var.vpn_client_aad_audience
    # aad_issuer           = var.vpn_client_aad_issuer
    # aad_tenant           = var.vpn_client_aad_tenant
    vpn_auth_types       = var.vpn_auth_types
    vpn_client_protocols = var.vpn_client_protocols
    root_certificate {
      name             = var.root_certificate_name_1
      public_cert_data = var.public_cert_data_1
    }
    root_certificate {
      name             = var.root_certificate_name_2
      public_cert_data = var.public_cert_data_2
    }
  }

  tags       = var.vpn_gateway_tags
  depends_on = [azurerm_public_ip.hub_vpn_gateway1_pip]
}


#################################
# VPN - Local network gateway
#################################

resource "azurerm_local_network_gateway" "hub_local_network_gateway" {
  name                = var.local_network_gateway_name
  resource_group_name = var.hub_resource_group
  location            = var.hub_location
  gateway_address     = var.local_network_gateway_pip
  address_space       = var.local_network_address_space
  depends_on          = [azurerm_virtual_network_gateway.hub_vnet_gateway]
}


############################
# VPN - VPN connection
############################

resource "azurerm_virtual_network_gateway_connection" "vpn_connection" {
  name                               = var.vpn_connection_name
  resource_group_name                = var.hub_resource_group
  location                           = var.hub_location
  type                               = var.vpn_connection_type
  virtual_network_gateway_id         = azurerm_virtual_network_gateway.hub_vnet_gateway.id
  local_network_gateway_id           = azurerm_local_network_gateway.hub_local_network_gateway.id
  use_policy_based_traffic_selectors = false

  shared_key = var.ipsec_shared_key

  ipsec_policy {
    dh_group         = var.dh_group
    ike_encryption   = var.ike_encryption
    ike_integrity    = var.ike_integrity
    ipsec_encryption = var.ipsec_encryption
    ipsec_integrity  = var.ipsec_integrity
    pfs_group        = var.pfs_group
    sa_lifetime      = var.sa_lifetime
  }

  depends_on = [azurerm_local_network_gateway.hub_local_network_gateway]
}



# Deploy Hub Virtual Network and subnets
module "hub_network" {
  source = "../../modules/hub_network"

  providers          = { azurerm = azurerm.connectivity }
  hub_resource_group = var.hub_resource_group
  hub_location       = var.hub_location
  hub_vnet_name      = var.hub_vnet_name
  hub_vnet_cidr      = var.hub_vnet_cidr
  gateway_subnet     = var.gateway_subnet
  firewall_subnet    = var.firewall_subnet
  hub_tags           = var.global_tags
  dns_servers        = var.dns_servers
  conn_vnet_subnets  = var.conn_vnet_subnets
  # hub_dnsr_subnets       = var.hub_dnsr_subnets
  vpn_gateway_udr_name   = var.vpn_gateway_udr_name
  vpn_gateway_udr_routes = var.vpn_gateway_udr_routes
  vpn_gateway_tags       = var.global_tags
}

# Deploy a Spoke network - Prod
module "prod_spoke_network" {
  source     = "../../modules/spoke_network"
  depends_on = [module.hub_network]

  providers = { azurerm.spoke = azurerm.prod
  azurerm.connectivity = azurerm.connectivity }
  spoke_location       = var.prod_vnet_location
  spoke_resource_group = var.prod_resource_group
  spoke_vnet_name      = var.prod_vnet_name
  spoke_vnet_cidr      = var.prod_vnet_cidr
  hub_vnet_id          = module.hub_network.hub_vnet_id
  hub_resource_group   = var.hub_resource_group
  hub_vnet_name        = var.hub_vnet_name
  spoke_vnet_subnets   = var.prod_vnet_subnets
  spoke_udr_name       = var.prod_udr_name
  spoke_udr_routes     = var.prod_udr_routes
  spoke_tags           = var.global_tags
  dns_servers          = var.dns_servers
  peer_remote_gw       = var.peer_remote_gw
  peer_gateway_transit = var.peer_gateway_transit
}

# Deploy a Spoke network - Dev
module "dev_spoke_network" {
  source     = "../../modules/spoke_network"
  depends_on = [module.hub_network]

  providers = { azurerm.spoke = azurerm.dev
  azurerm.connectivity = azurerm.connectivity }
  spoke_location       = var.dev_vnet_location
  spoke_resource_group = var.dev_resource_group
  spoke_vnet_name      = var.dev_vnet_name
  spoke_vnet_cidr      = var.dev_vnet_cidr
  hub_vnet_id          = module.hub_network.hub_vnet_id
  hub_resource_group   = var.hub_resource_group
  hub_vnet_name        = var.hub_vnet_name
  spoke_vnet_subnets   = var.dev_vnet_subnets
  spoke_udr_name       = var.dev_udr_name
  spoke_udr_routes     = var.dev_udr_routes
  peer_remote_gw       = var.dev_peer_remote_gw
  peer_gateway_transit = var.dev_peer_gateway_transit
  spoke_tags           = var.global_tags
  dns_servers          = var.dns_servers
}

# Deploy a Spoke network - Management
module "mgmt_spoke_network" {
  source     = "../../modules/spoke_network"
  depends_on = [module.hub_network]

  providers = { azurerm.spoke = azurerm.mgmt
  azurerm.connectivity = azurerm.connectivity }
  spoke_location       = var.mgmt_vnet_location
  spoke_resource_group = var.mgmt_resource_group
  spoke_vnet_name      = var.mgmt_vnet_name
  spoke_vnet_cidr      = var.mgmt_vnet_cidr
  hub_vnet_id          = module.hub_network.hub_vnet_id
  hub_resource_group   = var.hub_resource_group
  hub_vnet_name        = var.hub_vnet_name
  spoke_vnet_subnets   = var.mgmt_vnet_subnets
  spoke_udr_name       = var.mgmt_udr_name
  spoke_udr_routes     = var.mgmt_udr_routes
  peer_remote_gw       = var.mgmt_peer_remote_gw
  peer_gateway_transit = var.mgmt_peer_gateway_transit
  spoke_tags           = var.global_tags
  dns_servers          = var.dns_servers
}

# Deploy a Spoke network - Identity
module "identity_spoke_network" {
  source     = "../../modules/spoke_network"
  depends_on = [module.hub_network]

  providers = { azurerm.spoke = azurerm.identity
  azurerm.connectivity = azurerm.connectivity }
  spoke_location       = var.identity_vnet_location
  spoke_resource_group = var.identity_resource_group
  spoke_vnet_name      = var.identity_vnet_name
  spoke_vnet_cidr      = var.identity_vnet_cidr
  hub_vnet_id          = module.hub_network.hub_vnet_id
  hub_resource_group   = var.hub_resource_group
  hub_vnet_name        = var.hub_vnet_name
  spoke_vnet_subnets   = var.identity_vnet_subnets
  spoke_udr_name       = var.identity_udr_name
  spoke_udr_routes     = var.identity_udr_routes
  peer_remote_gw       = var.identity_peer_remote_gw
  peer_gateway_transit = var.identity_peer_gateway_transit
  spoke_tags           = var.global_tags
  dns_servers          = var.dns_servers
}

# Deploy VPN Gateway ~30min
module "vpn_gateway" {
  source = "../../modules/vpn_gateway"
  depends_on = [
    module.hub_network,
    #   module.er_gateway
  ]
  providers            = { azurerm = azurerm.connectivity }
  hub_location         = var.hub_location
  gateway_subnet_id    = module.hub_network.gateway_subnet_id
  hub_resource_group   = var.hub_resource_group
  vpn_gateway_name     = var.vpn_gateway_name
  vpn_gateway_sku      = var.vpn_gateway_sku
  vpn_gateway_type     = var.vpn_gateway_type
  vpn_gateway_vpn_type = var.vpn_gateway_vpn_type

  vpn_gateway_private_ip_address_allocation = var.vpn_gateway_private_ip_address_allocation
  vpn_gateway_custom_route_address_prefixes = var.vpn_gateway_custom_route_address_prefixes
  vpn_gateway_tags                          = var.global_tags

  # VPN Public IP
  vpn_gateway_pip_name                   = var.vpn_gateway_pip_name
  hub_vpn_gateway1_pip_allocation_method = var.hub_vpn_gateway1_pip_allocation_method
  hub_vpn_gateway1_pip_sku               = var.hub_vpn_gateway1_pip_sku
  hub_vpn_gateway1_pip_zones             = var.hub_vpn_gateway1_pip_zones

  # vpn_client_configuration
  vpn_client_address_space = var.vpn_client_address_space
  vpn_auth_types           = var.vpn_auth_types
  vpn_client_protocols     = var.vpn_client_protocols
  # vpn_client_aad_audience  = var.vpn_client_aad_audience
  # vpn_client_aad_issuer    = var.vpn_client_aad_issuer
  # vpn_client_aad_tenant    = var.vpn_client_aad_tenant
  root_certificate_name = var.root_certificate_name
  public_cert_data      = var.public_cert_data

  ############################
  # S2S VPN variables
  ############################
  ipsec_shared_key            = var.ipsec_shared_key
  local_network_gateway_name  = var.local_network_gateway_name
  vpn_connection_name         = var.vpn_connection_name
  vpn_connection_type         = var.vpn_connection_type
  local_network_gateway_pip   = var.local_network_gateway_pip
  local_network_address_space = var.local_network_address_space

  dh_group         = var.dh_group
  ike_encryption   = var.ike_encryption
  ike_integrity    = var.ike_integrity
  ipsec_encryption = var.ipsec_encryption
  ipsec_integrity  = var.ipsec_integrity
  pfs_group        = var.pfs_group
  sa_lifetime      = var.sa_lifetime
}

# Deploy Azure Firewall ~15min
module "azure_firewall" {
  source     = "../../modules/azure_firewall-v2"
  depends_on = [module.hub_network]

  providers                         = { azurerm = azurerm.connectivity }
  hub_location                      = var.hub_location
  firewall_subnet_id                = module.hub_network.firewall_subnet_id
  hub_resource_group                = var.hub_resource_group
  firewall_pip_name                 = var.firewall_pip_name
  firewall_pip_allocation_method    = var.firewall_pip_allocation_method
  firewall_pip_sku                  = var.firewall_pip_sku
  firewall_name                     = var.firewall_name
  firewall_policy_name              = var.firewall_policy_name
  firewall_sku_tier                 = var.firewall_sku_tier
  firewall_zones                    = var.firewall_zones
  firewall_tags                     = var.global_tags
  firewall_dnat_rule_collections    = var.firewall_dnat_rule_collections
  firewall_network_rule_collections = var.firewall_network_rule_collections
  firewall_app_rule_collections     = var.firewall_app_rule_collections
}

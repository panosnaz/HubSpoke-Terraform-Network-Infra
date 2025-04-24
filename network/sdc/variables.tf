###################################
# variables for SDC HUB environment 
###################################
variable "conn_sub_id" {
  description = "Connectivity Subscription ID"
  type        = string
}

variable "hub_resource_group" {
  description = "Hub resource group"
  type        = string
}
variable "hub_location" {
  description = "Location for hub resources"
  type        = string
}

variable "hub_vnet_name" {
  description = "Hub Virtual Network name"
  type        = string
}

variable "hub_vnet_cidr" {
  description = "Hub Virtual Network CIDR"
  type        = string
}
variable "conn_vnet_subnets" {
  description = "Subnets of connectivity Vnet"
  type        = map(any)
}
variable "gateway_subnet" {
  description = "Hub Virtual Network Gateway Subnet CIDR"
  type        = string
}
variable "firewall_subnet" {
  description = "Hub Virtual Network Azure Firewall Subnet CIDR"
  type        = string
}
variable "bastion_subnet" {
  description = "GWC Hub Virtual Network Bastion Subnet CIDR"
  type        = string
}
variable "bastion_host" {
  description = "GWC Hub Bastion Host name"
  type        = string
}
variable "bastion_ip" {
  description = "GWC Hub Bastion IP name"
  type        = string
}
###############################
# VNET Peerings
###############################

variable "peer_remote_gw" {
  type        = bool
  description = "Value to enable/disable peer remote gateway"
  default     = true
}
variable "peer_gateway_transit" {
  type        = bool
  description = "Variable to enable/disable Peering gateway transit"
}

###############################
# variables for PROD environment 
###############################

variable "prod_sub_id" {
  description = "prod Subscription ID"
  type        = string
}

variable "prod_resource_group" {
  description = "Resource Group for prod Vnet & subnets"
  type        = string
}

variable "prod_vnet_name" {
  description = "prod Vnet name"
  type        = string
}

variable "prod_vnet_location" {
  description = "prod Vnet location/region"
  type        = string
}

variable "prod_vnet_cidr" {
  description = "prod Vnet CIDR"
  type        = string
}

variable "prod_vnet_subnets" {
  description = "Subnets of prod Vnet"
  type        = map(any)
}

variable "prod_udr_name" {
  description = "UDR name of prod Vnet"
  type        = string
}

variable "prod_udr_routes" {
  description = "UDR routes of prod Vnet"
  type        = map(any)
}

variable "global_tags" {
  description = "Tags for all network resources"
  type        = map(any)
}

variable "dns_servers" {
  description = "DNS servers for all VNETs"
  type        = list(string)
  default     = []
}

###############################
# variables for DEV environment 
###############################

variable "dev_sub_id" {
  description = "dev Subscription ID"
  type        = string
}

variable "dev_resource_group" {
  description = "Resource Group for dev Vnet & subnets"
  type        = string
}

variable "dev_vnet_name" {
  description = "dev Vnet name"
  type        = string
}

variable "dev_vnet_location" {
  description = "dev Vnet location/region"
  type        = string
}

variable "dev_vnet_cidr" {
  description = "dev Vnet CIDR"
  type        = string
}

variable "dev_vnet_subnets" {
  description = "Subnets of dev Vnet"
  type        = map(any)
}

variable "dev_udr_name" {
  description = "UDR name of dev Vnet"
  type        = string
}

variable "dev_udr_routes" {
  description = "UDR routes of dev Vnet"
  type        = map(any)
}

variable "dev_peer_remote_gw" {
  description = "value for use remote gateway in peering"
  type        = bool
}
variable "dev_peer_gateway_transit" {
  type        = bool
  description = "Variable to enable/disable Peering gateway transit"
}

#####################################
# variables for Identity environment 
#####################################

variable "identity_sub_id" {
  description = "identity Subscription ID"
  type        = string
}
variable "identity_resource_group" {
  description = "Resource Group for identity Vnet & subnets"
  type        = string
}

variable "identity_vnet_name" {
  description = "identity Vnet name"
  type        = string
}

variable "identity_vnet_location" {
  description = "identity Vnet location/region"
  type        = string
}

variable "identity_vnet_cidr" {
  description = "identity Vnet CIDR"
  type        = string
}

variable "identity_vnet_subnets" {
  description = "Subnets of identity Vnet"
  type        = map(any)
}

variable "identity_udr_name" {
  description = "UDR name of identity Vnet"
  type        = string
}

variable "identity_udr_routes" {
  description = "UDR routes of identity Vnet"
  type        = map(any)
}

variable "identity_peer_remote_gw" {
  description = "value for use remote gateway in peering"
  type        = bool
}
variable "identity_peer_gateway_transit" {
  type        = bool
  description = "Variable to enable/disable Peering gateway transit"
}
#######################################
# variables for Management environment 
#######################################
variable "mgmt_sub_id" {
  description = "mgmt Subscription ID"
  type        = string
}
variable "mgmt_resource_group" {
  description = "Resource Group for mgmt Vnet & subnets"
  type        = string
}

variable "mgmt_vnet_name" {
  description = "mgmt Vnet name"
  type        = string
}

variable "mgmt_vnet_location" {
  description = "mgmt Vnet location/region"
  type        = string
}

variable "mgmt_vnet_cidr" {
  description = "mgmt Vnet CIDR"
  type        = string
}

variable "mgmt_vnet_subnets" {
  description = "Subnets of mgmt Vnet"
  type        = map(any)
}

variable "mgmt_udr_name" {
  description = "UDR name of mgmt Vnet"
  type        = string
}

variable "mgmt_udr_routes" {
  description = "UDR routes of mgmt Vnet"
  type        = map(any)
}

variable "mgmt_peer_remote_gw" {
  description = "value for use remote gateway in peering"
  type        = bool
}
variable "mgmt_peer_gateway_transit" {
  type        = bool
  description = "Variable to enable/disable Peering gateway transit"
}

############################
# VPN GW variables 
############################
variable "vpn_gateway_location" {
  description = "vpn_gateway_location"
  type        = string
}
variable "vpn_gateway_pip_name" {
  description = "VPN Public IP name"
  type        = string
}
variable "vpn_gateway_name" {
  description = "VPN Gateway name"
  type        = string
}
variable "vpn_gateway_sku" {
  description = "VPN Gateway SKU"
  type        = string
}
variable "vpn_gateway_type" {
  description = "VPN Gateway type"
  type        = string
}
variable "vpn_gateway_vpn_type" {
  description = "VPN Gateway VPN type"
  type        = string
}
variable "vpn_gateway_udr_name" {
  description = "Route table name for VPN gateway subnet"
  type        = string
}
variable "vpn_gateway_udr_routes" {
  description = "UDR routes for the VPN gateway subnet"
  type        = map(any)
}
variable "vpn_gateway_custom_route_address_prefixes" {
  description = "VPN Gateway Custom route address prefixes"
  type        = list(string)
}

variable "vpn_gateway_private_ip_address_allocation" {
  description = "VPN Gateway private IP address assignment method"
  type        = string
}
variable "hub_vpn_gateway1_pip_allocation_method" {
  description = "VPN Gateway Public IP allocation_method"
  type        = string
}
variable "hub_vpn_gateway1_pip_sku" {
  description = "VPN Gateway Public IP sku"
  type        = string
}
variable "hub_vpn_gateway1_pip_zones" {
  description = "VPN Gateway Public IP zones"
  type        = list(string)
}

variable "vpn_client_address_space" {
  description = "VPN Gateway Client address space"
  type        = list(string)
}
variable "vpn_auth_types" {
  description = "VPN Gateway auth types"
  type        = list(string)
}
variable "root_certificate_name" {
  description = "p2s VPN root certificate"
  type        = string
}
variable "public_cert_data" {
  description = "p2s VPN public_cert_data"
  type        = string
}
variable "vpn_client_protocols" {
  description = "VPN Gateway client protocols"
  type        = list(string)
}
# variable "vpn_client_aad_audience" {
#   description = "VPN Gateway AAD audience"
#   type        = string
# }
# variable "vpn_client_aad_issuer" {
#   description = "VPN Gateway AAD issuer"
#   type        = string
# }
# variable "vpn_client_aad_tenant" {
#   description = "VPN Gateway AAD Tenant"
#   type        = string
# }

############################
# VPN variables
############################
variable "local_network_gateway_name" {
  description = "Local Network Gateway name"
  type        = string
}
variable "local_network_gateway_pip" {
  description = "Local Network Gateway Public IP"
  type        = string
}
variable "local_network_address_space" {
  description = "Local Network Gateway address space"
  type        = list(string)
}
variable "vpn_connection_name" {
  description = "VPN Gateway connection name"
  type        = string
}
variable "ipsec_shared_key" {
  description = "ipsec shared key for the VPN connection"
  type        = string
}
variable "vpn_connection_type" {
  description = "VPN Gateway connection type"
  type        = string
}

variable "dh_group" {
  description = "DH Group for the ipsec policy"
  type        = string
}
variable "ike_encryption" {
  description = "ike encryption for the ipsec policy"
  type        = string
}
variable "ike_integrity" {
  description = "ike integrity for the ipsec policy"
  type        = string
}
variable "ipsec_encryption" {
  description = "ipsec encryption for the ipsec policy"
  type        = string
}
variable "ipsec_integrity" {
  description = "ipsec integrity for the ipsec policy"
  type        = string
}
variable "pfs_group" {
  description = "pfs group for the ipsec policy"
  type        = string
}
variable "sa_lifetime" {
  description = "sa lifetime for the ipsec policy"
  type        = string
}

############################
# Firewall variables 
############################

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
  default     = "Premium"
}
variable "firewall_zones" {
  description = "Firewall Availability Zones"
  type        = list(string)
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

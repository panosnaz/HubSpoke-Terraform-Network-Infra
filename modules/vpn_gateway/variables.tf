variable "hub_location" {
  description = "Location for hub resources"
  type        = string
}
variable "gateway_subnet_id" {
  description = "Gateway Subnet for Virtual Network Gateways"
  type        = string
}
variable "hub_resource_group" {
  description = "Hub resource group"
  type        = string
}
variable "vpn_gateway_pip_name" {
  description = "ER Public IP name"
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
variable "vpn_gateway_tags" {
  description = "VPN Gateway Tags"
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
variable "root_certificate_name_1" {
  description = "p2s VPN root certificate"
  type        = string
}
variable "public_cert_data_1" {
  description = "p2s VPN public_cert_data"
  type        = string
}
variable "root_certificate_name_2" {
  description = "p2s VPN root certificate"
  type        = string
}
variable "public_cert_data_2" {
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
# S2S VPN variables
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
variable "vpn_connection_type" {
  description = "VPN Gateway connection type"
  type        = string
}
variable "ipsec_shared_key" {
  description = "ipsec shared key for the VPN connection"
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

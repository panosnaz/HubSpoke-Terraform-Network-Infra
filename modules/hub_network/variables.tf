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
variable "gateway_subnet" {
  description = "Hub Virtual Network GatewaySubnet CIDR"
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
variable "firewall_subnet" {
  description = "Hub Virtual Network AzureFirewallSubnet CIDR"
  type        = string
}

variable "hub_tags" {
  description = "Hub network tags"
  type        = map(any)
}

variable "dns_servers" {
  description = "DNS servers of Hub VNET"
  type        = list(string)
}



variable "vpn_gateway_udr_name" {
  description = "Route table name for VPN gateway subnet"
  type        = string
}
variable "vpn_gateway_udr_routes" {
  description = "UDR routes for the VPN gateway subnet"
  type        = map(any)
}
variable "vpn_gateway_tags" {
  description = "VPN Gateway Tags"
  type        = map(any)
}

variable "conn_vnet_subnets" {
  description = "Subnets of connectivity Vnet"
  type        = map(any)
}
# variable "hub_dnsr_subnets" {
#   description = "hub_dnsr_subnets"
#   type        = map(any)
# }

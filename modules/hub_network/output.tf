output "hub_vnet_id" {
  description = "The resource ID of the Hub's virtual network"
  value       = azurerm_virtual_network.hub_vnet.id
}

output "gateway_subnet_id" {
  description = "The resource ID of the virtual network gateway subnet"
  value       = azurerm_subnet.hub_gateway_subnet.id
}

output "firewall_subnet_id" {
  description = "The resource ID of the Azure firewall subnet"
  value       = azurerm_subnet.hub_firewall_subnet.id
}

# output "bastion_subnet_id" {
#   description = "The resource ID of the bastion subnet"
#   value       = azurerm_subnet.hub_bastion_subnet.id
# }

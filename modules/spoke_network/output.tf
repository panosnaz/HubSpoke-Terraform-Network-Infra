# output "spoke_subnet_id" {
#   value =values(data.azurerm_subnet.subnets).*.id
# }

output "spoke_subnet_id" {
  value =values(azurerm_subnet.spoke_subnet).*.id
}
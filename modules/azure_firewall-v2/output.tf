output "firewall_private_ip" {
  value = azurerm_firewall.azure_firewall.ip_configuration[0].private_ip_address
}
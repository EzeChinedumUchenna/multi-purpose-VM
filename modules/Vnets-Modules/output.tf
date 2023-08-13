output "vnet" {
  value = azurerm_virtual_network.my_terraform_network
}

output "subnet" {
  value = azurerm_subnet.my_terraform_subnet
}

output "nsg" {
  value= azurerm_network_security_group.my_terraform_nsg
}
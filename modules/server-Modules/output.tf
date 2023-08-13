output "network_interface" {
 value = azurerm_network_interface.my_terraform_nic
}

output "vm" {
  value = azurerm_windows_virtual_machine.main
}

output "IP" {
  value = azurerm_public_ip.my_terraform_public_ip
}
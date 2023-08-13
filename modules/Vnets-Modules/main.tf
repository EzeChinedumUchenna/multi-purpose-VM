# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  //name                = "${random_pet.prefix.id}-vnet"
  name                = "${var.my_name}-${var.env}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_location
  resource_group_name = var.rg_name
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "${var.my_name}-${var.env}-subnet"
  resource_group_name  = azurerm_virtual_network.my_terraform_network.resource_group_name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Network Security Group and rules
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "${var.my_name}-${var.env}-nsg"
  location            = azurerm_virtual_network.my_terraform_network.location
  resource_group_name = azurerm_virtual_network.my_terraform_network.resource_group_name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
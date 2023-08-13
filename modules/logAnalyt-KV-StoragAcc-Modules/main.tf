# Create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "${var.my_name}${var.env}storageaccount"
  location                 = var.rg_location
  resource_group_name      = var.rg_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a Recovery Vault Service (RSV)
resource "azurerm_recovery_services_vault" "rsv" {
  name                = "${var.my_name}-${var.env}-rsv"
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = "Standard"
  soft_delete_enabled = false

  depends_on = [ var.vm ]
}

// depends_on = [ azurerm_windows_virtual_machine.main ]

# Creates Log Anaylytics Workspace
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.my_name}-${var.env}-workAnalyticsWorkspace"
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


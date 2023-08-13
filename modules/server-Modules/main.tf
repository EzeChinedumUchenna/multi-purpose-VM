# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "${var.my_name}-${var.env}-public-ip"
  location            = var.resource_location
  resource_group_name = var.rg_name
  allocation_method   = "Dynamic"
}



# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "${var.my_name}-${var.env}-nic"
  location            = var.resource_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}


# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsg-nic" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = var.network_security_group_id
}


# Create virtual machine
resource "azurerm_windows_virtual_machine" "main" {
  name                  = var.my_name
  admin_username        = "chinedumeze"
  admin_password        = "Fitb@5044444"
  # admin_password        = random_password.password.result
  location              = var.resource_location
  resource_group_name   = azurerm_network_interface.my_terraform_nic.resource_group_name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

    boot_diagnostics {
    storage_account_uri = var.storageaccount_primary_blob_endpoint
  }


}




/**# Install IIS web server to the virtual machine
resource "azurerm_virtual_machine_extension" "web_server_install" {
  name                       = "${var.company_name}-${var.env}-IIS"
  virtual_machine_id         = azurerm_windows_virtual_machine.main.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "myExecutionCommand",
        "storageAccountName": "myStorageAccountName",
        "storageAccountKey": "myStorageAccountKey",
        "managedIdentity" : {}
    }
PROTECTED_SETTINGS
}**/


# Create microsoft monitoring agent that will send the log from VM to the work Analytics workspace
resource "azurerm_virtual_machine_extension" "mmaagent" {
  name                 = "mmaagent"
  virtual_machine_id   = azurerm_windows_virtual_machine.main.id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "MicrosoftMonitoringAgent"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = "true"
  settings = <<SETTINGS
    {
      "workspaceId": "${var.workspace_id}"
    }
SETTINGS
   protected_settings = <<PROTECTED_SETTINGS
   {
      "workspaceKey": "${var.logAnalytics_primary_shared_key}"
      
   }
PROTECTED_SETTINGS

depends_on = [ azurerm_virtual_machine_extension.mmaagent ]
}

//"workspaceKey": "${azurerm_log_analytics_workspace.law.primary_shared_key}"



# BackUp policy to RSV for VM
resource "azurerm_backup_policy_vm" "backuppolicy" {
  name                = "${var.my_name}-${var.env}-bpvmw"
  resource_group_name = var.rg_name
  recovery_vault_name = var.rsv_name

    timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

  retention_weekly {
    count    = 42
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"]
  }

  retention_monthly {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }

  retention_yearly {
    count    = 77
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }
}

resource "azurerm_backup_protected_vm" "backupProtect" {
  resource_group_name = var.rg_name
  recovery_vault_name = var.rsv_name
  source_vm_id        = azurerm_windows_virtual_machine.main.id
  backup_policy_id    = azurerm_backup_policy_vm.backuppolicy.id
}

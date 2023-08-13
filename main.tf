resource "azurerm_resource_group" "rg" {
  location = var.rg_location
  name     = "${var.my_name}-${var.env}-rg"
  // name     = "${random_pet.prefix.id}-rg"

}



module "vnet_modules" {
  source            = "./modules/Vnets-Modules"
  my_name           = var.my_name
  env               = var.env
  resource_location = var.resource_location
  rg_name           = azurerm_resource_group.rg.name


}

module "logAnalytic-KV-storage-modules" {
  source      = "./modules/logAnalyt-KV-StoragAcc-Modules"
  my_name     = var.my_name
  env         = var.env
  rg_location = azurerm_resource_group.rg.location
  rg_name     = azurerm_resource_group.rg.name
  vm          = module.server-modules.vm

}


module "server-modules" {
  source                               = "./modules/server-Modules"
  my_name                              = "${var.my_name}-vm"
  rg_name                              = azurerm_resource_group.rg.name
  env                                  = var.env
  resource_location                    = var.resource_location
  subnet_id                            = module.vnet_modules.subnet.id
  network_security_group_id            = module.vnet_modules.nsg.id
  storageaccount_primary_blob_endpoint = module.logAnalytic-KV-storage-modules.storage.primary_blob_endpoint
  workspace_id                         = module.logAnalytic-KV-storage-modules.logAnalyticWorkspace.workspace_id
  logAnalytics_primary_shared_key      = module.logAnalytic-KV-storage-modules.logAnalyticWorkspace.primary_shared_key
  rsv_name                             = module.logAnalytic-KV-storage-modules.RSV.name
  public_ip_address_id                 = {}
}




















/**# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

resource "random_pet" "prefix" {
  prefix = var.prefix
  length = 1
}**/



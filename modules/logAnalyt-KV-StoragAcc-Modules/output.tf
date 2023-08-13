output "storage" {
    value = azurerm_storage_account.my_storage_account
}

output "RSV" {
    value = azurerm_recovery_services_vault.rsv
}

output "logAnalyticWorkspace" {
    value = azurerm_log_analytics_workspace.law
}


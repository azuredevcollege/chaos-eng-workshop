# CosmosDB

resource "azurerm_cosmosdb_account" "cda" {
  name                = "${var.prefix}cda${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  enable_multiple_write_locations = true

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  geo_location {
    location          = var.failover_location
    failover_priority = 1
  }

  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

resource "azurerm_cosmosdb_sql_database" "cda_database" {
  name                = var.cosmosdbname
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cda.name
  throughput          = 4000
}

resource "azurerm_cosmosdb_sql_container" "cda_database_container" {
  name                = var.cosmoscontainername
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cda.name
  database_name       = azurerm_cosmosdb_sql_database.cda_database.name
  partition_key_path  = "/type"
}

# Azure SQL DB

resource "azurerm_mssql_server" "sqlsrv" {
  name                         = "${var.prefix}sqlsrv${var.env}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sqldbusername
  administrator_login_password = var.sqldbpassword

  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "${var.prefix}sqldb${var.env}"
  server_id = azurerm_mssql_server.sqlsrv.id
  sku_name  = "S0"
  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

resource "azurerm_mssql_firewall_rule" "sqldb" {
  name             = "FirewallRule1"
  server_id        = azurerm_mssql_server.sqlsrv.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# SEARCH

resource "azurerm_search_service" "search" {
  name                = "${var.prefix}search${var.env}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "basic"

  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

# Cognitive Services

resource "azurerm_cognitive_account" "textanalytics" {
  name                = "${var.prefix}cognitive${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "TextAnalytics"

  sku_name = "F0"

  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

output "cosmos_endpoint" {
  value       = azurerm_cosmosdb_account.cda.endpoint
  description = "Cosmo DB Endpoint"
}

output "cosmosDbName" {
  value       = azurerm_cosmosdb_account.cda.name
  description = "Cosmo DB Account Name"
}

output "cosmosDbId" {
  value       = azurerm_cosmosdb_account.cda.id
  description = "Cosmo DB Account ID"
}

output "cosmos_primary_master_key" {
  value       = azurerm_cosmosdb_account.cda.primary_key
  description = "Cosmo DB Primary Master key"
}

output "cosmos_secondary_master_key" {
  value       = azurerm_cosmosdb_account.cda.secondary_key
  description = "Cosmo DB Primary Master key"
}

output "sqldb_connectionstring" {
  value       = "Server=tcp:${azurerm_mssql_server.sqlsrv.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sqldb.name};Persist Security Info=False;User ID=${azurerm_mssql_server.sqlsrv.administrator_login};Password=${azurerm_mssql_server.sqlsrv.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  description = "SQL DB Connection String"
}

output "search_primary_key" {
  value       = azurerm_search_service.search.primary_key
  description = "Search Primary Key"
}

output "search_name" {
  value       = azurerm_search_service.search.name
  description = "Search Name"
}

output "textanalytics_endpoint" {
  value = azurerm_cognitive_account.textanalytics.endpoint
}

output "textanalytics_key" {
  value = azurerm_cognitive_account.textanalytics.primary_access_key
}


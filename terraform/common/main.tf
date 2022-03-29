data "azurerm_client_config" "current" {
}

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.prefix}ai${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  retention_in_days   = 90
  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

output "ai_instrumentation_key" {
  value       = azurerm_application_insights.appinsights.instrumentation_key
  description = "Application Insights Instrumentation Key"
}

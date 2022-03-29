resource "azurerm_servicebus_namespace" "sbn" {
  name                = "${var.prefix}sbn${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

# Thumbnail Queue

resource "azurerm_servicebus_queue" "queue_thumbnails" {
  name         = "thumbnails"
  namespace_id = azurerm_servicebus_namespace.sbn.id
}

resource "azurerm_servicebus_queue_authorization_rule" "queue_thumbnails_listen" {
  name     = "thumbnailslisten"
  queue_id = azurerm_servicebus_queue.queue_thumbnails.id

  listen = true
  send   = false
  manage = false
}

resource "azurerm_servicebus_queue_authorization_rule" "queue_thumbnails_send" {
  name     = "thumbnailssend"
  queue_id = azurerm_servicebus_queue.queue_thumbnails.id

  listen = false
  send   = true
  manage = false
}

# Contacts Topic

resource "azurerm_servicebus_topic" "contacts" {
  name         = "scmtopic"
  namespace_id = azurerm_servicebus_namespace.sbn.id
}

resource "azurerm_servicebus_topic_authorization_rule" "topic_contacts_listen" {
  name     = "scmtopiclisten"
  topic_id = azurerm_servicebus_topic.contacts.id
  listen   = true
  send     = false
  manage   = false
}

resource "azurerm_servicebus_topic_authorization_rule" "topic_contacts_send" {
  name     = "scmtopicsend"
  topic_id = azurerm_servicebus_topic.contacts.id
  listen   = false
  send     = true
  manage   = false
}

resource "azurerm_servicebus_subscription" "contacts_search" {
  name               = "scmcontactsearch"
  topic_id           = azurerm_servicebus_topic.contacts.id
  max_delivery_count = 10
  requires_session   = true
}

resource "azurerm_servicebus_subscription" "contacts_visitreport" {
  name               = "scmcontactvisitreport"
  topic_id           = azurerm_servicebus_topic.contacts.id
  max_delivery_count = 10
  requires_session   = false
}

# Contacts Topic

resource "azurerm_servicebus_topic" "visitreports" {
  name         = "scmvrtopic"
  namespace_id = azurerm_servicebus_namespace.sbn.id
}

resource "azurerm_servicebus_topic_authorization_rule" "topic_visitreports_listen" {
  name     = "scmvrtopiclisten"
  topic_id = azurerm_servicebus_topic.visitreports.id

  listen = true
  send   = false
  manage = false
}

resource "azurerm_servicebus_topic_authorization_rule" "topic_visitreports_send" {
  name     = "scmvrtopicsend"
  topic_id = azurerm_servicebus_topic.visitreports.id

  listen = false
  send   = true
  manage = false
}

resource "azurerm_servicebus_subscription" "visitreports_textanalytics" {
  name               = "scmvisitreporttextanalytics"
  topic_id           = azurerm_servicebus_topic.visitreports.id
  max_delivery_count = 10
  requires_session   = false
}

# Outputs

output "thumbnail_listen_connectionstring" {
  value = "Endpoint=sb://${azurerm_servicebus_namespace.sbn.name}.servicebus.windows.net/;SharedAccessKeyName=${azurerm_servicebus_queue_authorization_rule.queue_thumbnails_listen.name};SharedAccessKey=${azurerm_servicebus_queue_authorization_rule.queue_thumbnails_listen.primary_key}"
}

output "thumbnail_send_connectionstring" {
  value = azurerm_servicebus_queue_authorization_rule.queue_thumbnails_send.primary_connection_string
}

output "contacts_send_connectionstring" {
  value = azurerm_servicebus_topic_authorization_rule.topic_contacts_send.primary_connection_string
}

output "contacts_listen_with_entity_connectionstring" {
  value = azurerm_servicebus_topic_authorization_rule.topic_contacts_listen.primary_connection_string
}

output "contacts_listen_connectionstring" {
  value = "Endpoint=sb://${azurerm_servicebus_namespace.sbn.name}.servicebus.windows.net/;SharedAccessKeyName=${azurerm_servicebus_topic_authorization_rule.topic_contacts_listen.name};SharedAccessKey=${azurerm_servicebus_topic_authorization_rule.topic_contacts_listen.primary_key}"
}

output "visitreports_send_connectionstring" {
  value = azurerm_servicebus_topic_authorization_rule.topic_visitreports_send.primary_connection_string
}

output "visitreports_listen_connectionstring_old" {
  value = azurerm_servicebus_topic_authorization_rule.topic_visitreports_listen.primary_connection_string
}

output "visitreports_listen_connectionstring" {
  value = "Endpoint=sb://${azurerm_servicebus_namespace.sbn.name}.servicebus.windows.net/;SharedAccessKeyName=${azurerm_servicebus_topic_authorization_rule.topic_visitreports_listen.name};SharedAccessKey=${azurerm_servicebus_topic_authorization_rule.topic_visitreports_listen.primary_key}"
}


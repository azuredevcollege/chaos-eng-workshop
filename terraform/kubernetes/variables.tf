variable "location" {
  type = string
}

variable "prefix" {
  type = string
}

variable "env" {
  type    = string
}

variable "k8sversion" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sqlpwd" {
  type = string
}

variable "ai_instrumentation_key" {
  type = string
}

variable "thumbnail_listen_connectionstring" {
  type = string
}

variable "thumbnail_send_connectionstring" {
  type = string
}

variable "contacts_send_connectionstring" {
  type = string
}

variable "contacts_listen_with_entity_connectionstring" {
  type = string
}

variable "contacts_listen_connectionstring" {
  type = string
}

variable "visitreports_send_connectionstring" {
  type = string
}

variable "visitreports_listen_connectionstring" {
  type = string
}

variable "cosmos_endpoint" {
  type = string
}

variable "cosmos_primary_master_key" {
  type = string
}

variable "cosmos_secondary_master_key" {
  type = string
}

variable "sqldb_connectionstring" {
  type = string
}

variable "search_primary_key" {
  type = string
}

variable "search_name" {
  type = string
}

variable "textanalytics_endpoint" {
  type = string
}

variable "textanalytics_key" {
  type = string
}

variable "resources_primary_connection_string" {
  type = string
}

variable "funcs_primary_connection_string" {
  type = string
}

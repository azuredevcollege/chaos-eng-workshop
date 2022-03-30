terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.2"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}


resource "azurerm_resource_group" "k8s" {
  name     = "${var.prefix}-k8s-rg"
  location = var.location
  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

resource "azurerm_resource_group" "common" {
  name     = "${var.prefix}-common-rg"
  location = var.location
  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

# Base Resource Groups

resource "azurerm_resource_group" "data" {
  name     = "${var.prefix}-data-rg"
  location = var.location
  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

resource "azurerm_resource_group" "storage" {
  name     = "${var.prefix}-storage-rg"
  location = var.location
  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

resource "azurerm_resource_group" "messaging" {
  name     = "${var.prefix}-messaging-rg"
  location = var.location
  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

# Modules

module "common" {
  source              = "./common"
  location            = azurerm_resource_group.common.location
  resource_group_name = azurerm_resource_group.common.name
  env                 = var.env
  prefix              = var.prefix
}

module "data" {
  source              = "./data"
  location            = azurerm_resource_group.data.location
  failover_location   = var.failover_location
  resource_group_name = azurerm_resource_group.data.name
  env                 = var.env
  prefix              = var.prefix
  cosmosdbname        = var.cosmosdbname
  cosmoscontainername = var.cosmoscontainername
  sqldbusername       = var.sqldbusername
  sqldbpassword       = var.sqldbpassword
}

module "storage" {
  source              = "./storage"
  location            = azurerm_resource_group.storage.location
  resource_group_name = azurerm_resource_group.storage.name
  env                 = var.env
  prefix              = var.prefix
}

module "messaging" {
  source              = "./messaging"
  location            = azurerm_resource_group.messaging.location
  resource_group_name = azurerm_resource_group.messaging.name
  env                 = var.env
  prefix              = var.prefix
}

module "kubernetes" {
  source                                       = "./kubernetes"
  location                                     = azurerm_resource_group.k8s.location
  resource_group_name                          = azurerm_resource_group.k8s.name
  env                                          = var.env
  prefix                                       = var.prefix
  k8sversion                                   = var.k8sversion
  sqlpwd                                       = var.sqldbpassword
  ai_instrumentation_key                       = module.common.ai_instrumentation_key
  thumbnail_listen_connectionstring            = module.messaging.thumbnail_listen_connectionstring
  thumbnail_send_connectionstring              = module.messaging.thumbnail_send_connectionstring
  contacts_send_connectionstring               = module.messaging.contacts_send_connectionstring
  contacts_listen_with_entity_connectionstring = module.messaging.contacts_listen_with_entity_connectionstring
  contacts_listen_connectionstring             = module.messaging.contacts_listen_connectionstring
  visitreports_send_connectionstring           = module.messaging.visitreports_send_connectionstring
  visitreports_listen_connectionstring         = module.messaging.visitreports_listen_connectionstring
  cosmos_endpoint                              = module.data.cosmos_endpoint
  cosmos_primary_master_key                    = module.data.cosmos_primary_master_key
  cosmos_secondary_master_key                  = module.data.cosmos_secondary_master_key
  sqldb_connectionstring                       = module.data.sqldb_connectionstring
  search_primary_key                           = module.data.search_primary_key
  search_name                                  = module.data.search_name
  textanalytics_endpoint                       = module.data.textanalytics_endpoint
  textanalytics_key                            = module.data.textanalytics_key
  resources_primary_connection_string          = module.storage.resources_primary_connection_string
  funcs_primary_connection_string              = module.storage.funcs_primary_connection_string
}

output "nip_hostname" {
  value = module.kubernetes.nip_hostname
}

output "ai_ik" {
  value     = module.common.ai_instrumentation_key
  sensitive = true
}

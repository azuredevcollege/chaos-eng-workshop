variable "location" {
  type    = string
  default = "westeurope"
}

variable "failover_location" {
  type    = string
  default = "northeurope"
}

variable "k8sversion" {
  type    = string
  default = "1.22.6"
}

variable "prefix" {
  type    = string
  default = "cheng"
  validation {
    condition     = length(var.prefix) <= 6
    error_message = "The prefix value must not be longer than 6 characters."
  }
}

variable "env" {
  type    = string
  default = "dev"
}

variable "cosmosdbname" {
  type    = string
  default = "scmvisitreports"
}

variable "cosmoscontainername" {
  type    = string
  default = "visitreports"
}

variable "sqldbusername" {
  type    = string
  default = "adcsqladmin"
}

variable "sqldbpassword" {
  type    = string
  default = "Ch@ngeMe!123!"
}

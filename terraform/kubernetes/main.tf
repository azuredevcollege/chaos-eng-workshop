resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.prefix}k8s${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.prefix}k8s${var.env}"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  kubernetes_version = var.k8sversion

  tags = {
    environment = var.env
    source      = "chaos-eng-workshop"
  }
}

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.k8s.fqdn
  client_certificate = base64decode(
    azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate,
  )
  client_key = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(
    azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate,
  )
}

resource "kubernetes_namespace" "appns" {
  metadata {
    name = "contactsapp"
  }
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "contactsingress"
  }
}

resource "azurerm_public_ip" "ingress_ip" {
  name                = "contactsapp-ingressip"
  location            = var.location
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

provider "helm" {
  kubernetes {
    host               = azurerm_kubernetes_cluster.k8s.kube_config[0].host
    client_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
    client_key         = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(
      azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate,
    )
  }
}

resource "helm_release" "ingress" {
  name       = "contactsingress"
  chart      = "ingress-nginx"
  version    = "4.0.17"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace  = kubernetes_namespace.ingress.metadata[0].name

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "controller.replicaCount"
    value = 2
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.ingress_ip.ip_address
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = azurerm_kubernetes_cluster.k8s.node_resource_group
  }
}


resource "kubernetes_namespace" "chaostesting" {
  metadata {
    name = "chaos-testing"
  }
}

resource "helm_release" "chaos_mesh" {
  name       = "chaos-mesh"
  chart      = "chaos-mesh"
  version    = "2.1.3"
  repository = "https://charts.chaos-mesh.org"
  namespace  = kubernetes_namespace.chaostesting.metadata[0].name

  set {
    name  = "chaosDaemon.runtime"
    value = "containerd"
  }

  set {
    name  = "chaosDaemon.socketPath"
    value = "/run/containerd/containerd.sock"
  }
}

provider "kubectl" {
  load_config_file       = false
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
}

locals {
  hostname                                       = "${replace(azurerm_public_ip.ingress_ip.ip_address, ".", "-")}.nip.io"
  sql_connection_string64                        = base64encode(var.sqldb_connectionstring)
  ai_instrumentation_key                         = var.ai_instrumentation_key
  ai_instrumentation_key64                       = base64encode(var.ai_instrumentation_key)
  thumbnail_listen_connectionstring64            = base64encode(var.thumbnail_listen_connectionstring)
  thumbnail_send_connectionstring64              = base64encode(var.thumbnail_send_connectionstring)
  contacts_send_connectionstring64               = base64encode(var.contacts_send_connectionstring)
  contacts_listen_with_entity_connectionstring64 = base64encode(var.contacts_listen_with_entity_connectionstring)
  contacts_listen_connectionstring64             = base64encode(var.contacts_listen_connectionstring)
  visitreports_send_connectionstring64           = base64encode(var.visitreports_send_connectionstring)
  visitreports_listen_connectionstring64         = base64encode(var.visitreports_listen_connectionstring)
  cosmos_endpoint64                              = base64encode(var.cosmos_endpoint)
  cosmos_primary_master_key64                    = base64encode(var.cosmos_primary_master_key)
  search_primary_key64                           = base64encode(var.search_primary_key)
  search_name64                                  = base64encode(var.search_name)
  textanalytics_endpoint64                       = base64encode(var.textanalytics_endpoint)
  textanalytics_key64                            = base64encode(var.textanalytics_key)
  resources_primary_connection_string64          = base64encode(var.resources_primary_connection_string)
  funcs_primary_connection_string64              = base64encode(var.funcs_primary_connection_string)
}

resource "kubectl_manifest" "scm_secrets" {
  yaml_body = replace(
    replace(
      replace(
        replace(
          replace(
            replace(
              replace(
                replace(
                  replace(
                    replace(
                      replace(
                        replace(
                          replace(
                            replace(
                              replace(
                                replace(
                                  replace(file("abspath(path.module)/../../apps/manifests/secrets.yaml"),
                                  "#{sqldb_connectionstring_base64}#", local.sql_connection_string64),
                                "#{appinsights_base64}#", local.ai_instrumentation_key64),
                              "#{thumbnail_listen_connectionstring_base64}#", local.thumbnail_listen_connectionstring64),
                            "#{thumbnail_send_connectionstring_base64}#", local.thumbnail_send_connectionstring64),
                          "#{contacts_send_connectionstring_base64}#", local.contacts_send_connectionstring64),
                        "#{contacts_listen_with_entity_connectionstring_base64}#", local.contacts_listen_with_entity_connectionstring64),
                      "#{contacts_listen_connectionstring_base64}#", local.contacts_listen_connectionstring64),
                    "#{visitreports_send_connectionstring_base64}#", local.visitreports_send_connectionstring64),
                  "#{visitreports_listen_connectionstring_base64}#", local.visitreports_listen_connectionstring64),
                "#{cosmos_endpoint_base64}#", local.cosmos_endpoint64),
              "#{cosmos_primary_master_key_base64}#", local.cosmos_primary_master_key64),
            "#{search_primary_key_base64}#", local.search_primary_key64),
          "#{search_name_base64}#", local.search_name64),
        "#{textanalytics_endpoint_base64}#", local.textanalytics_endpoint64),
      "#{textanalytics_key_base64}#", local.textanalytics_key64),
    "#{resources_primary_connection_string_base64}#", local.resources_primary_connection_string64),
  "#{funcs_primary_connection_string_base64}#", local.funcs_primary_connection_string64)
}

resource "kubectl_manifest" "scm_configmap" {
  yaml_body = replace(
    replace(file("abspath(path.module)/../../apps/manifests/configmap.yaml"),
    "#{HOSTNAME}#", local.hostname),
  "#{appinsights}#", local.ai_instrumentation_key)
}

resource "kubectl_manifest" "contacts_api_deployment" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/contacts-api-deployment.yaml")
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "contacts_api_hpa" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/contacts-api-hpa.yaml")
  depends_on = [kubectl_manifest.contacts_api_deployment]
}

resource "kubectl_manifest" "contacts_api_service" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/contacts-api-service.yaml")
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "contacts_api_ingress" {
  yaml_body  = replace(file("abspath(path.module)/../../apps/manifests/contacts-api-ingress.yaml"), "#{HOSTNAME}#", local.hostname)
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "ui_deployment" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/ui-deployment.yaml")
  depends_on = [kubectl_manifest.scm_configmap]
}

resource "kubectl_manifest" "ui_service" {
  yaml_body = file("${abspath(path.module)}/../../apps/manifests/ui-service.yaml")
}

resource "kubectl_manifest" "ui_ingress" {
  yaml_body = replace(file("abspath(path.module)/../../apps/manifests/ui-ingress.yaml"), "#{HOSTNAME}#", local.hostname)
}

resource "kubectl_manifest" "resources_api_deployment" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/resources-api-deployment.yaml")
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "resources_api_service" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/resources-api-service.yaml")
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "resources_api_ingress" {
  yaml_body  = replace(file("abspath(path.module)/../../apps/manifests/resources-api-ingress.yaml"), "#{HOSTNAME}#", local.hostname)
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "resources_func_deployment" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/resources-function-deployment.yaml")
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "search_api_deployment" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/search-api-deployment.yaml")
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "search_api_service" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/search-api-service.yaml")
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "search_api_ingress" {
  yaml_body  = replace(file("abspath(path.module)/../../apps/manifests/search-api-ingress.yaml"), "#{HOSTNAME}#", local.hostname)
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "search_func_deployment" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/search-function-deployment.yaml")
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "visitreport_api_deployment" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/visitreport-api-deployment.yaml")
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "visitreport_api_service" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/visitreport-api-service.yaml")
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "visitreport_api_ingress" {
  yaml_body  = replace(file("abspath(path.module)/../../apps/manifests/visitreport-api-ingress.yaml"), "#{HOSTNAME}#", local.hostname)
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "textanalytics_func_deployment" {
  yaml_body  = file("${abspath(path.module)}/../../apps/manifests/textanalytics-function-deployment.yaml")
  depends_on = [kubectl_manifest.scm_secrets]
}

resource "kubectl_manifest" "swagger_ingress" {
  yaml_body  = replace(file("abspath(path.module)/../../apps/manifests/swagger-ingress.yaml"), "#{HOSTNAME}#", local.hostname)
  depends_on = [kubectl_manifest.scm_secrets]
}

output "clusterName" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "clusterId" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "nip_hostname" {
  value = local.hostname
}

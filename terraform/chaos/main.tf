resource "azurerm_resource_group_template_deployment" "onboard-cluster-chaos" {
  name                = "onboard-k8s"
  resource_group_name = var.resource_group_name_k8s
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "clusterName" = {
      value = var.clusterName
    }
  })
  template_content = <<TEMPLATE
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "clusterName": {
            "type": "string",
            "metadata": {
                "description": "The name of the resource being enabled."
            }
        },
        "location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]",
            "metadata": {
                "description": "Location"
            }
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.ContainerService/managedClusters/providers/targets",
            "apiVersion": "2021-09-15-preview",
            "name": "[concat(parameters('clusterName'), '/', 'Microsoft.Chaos/Microsoft-AzureKubernetesServiceChaosMesh')]",
            "location": "[parameters('location')]",
            "properties": {}
        },
        {
            "type": "Microsoft.ContainerService/managedClusters/providers/targets/capabilities",
            "apiVersion": "2021-09-15-preview",
            "name": "[concat(parameters('clusterName'), '/', 'Microsoft.Chaos/Microsoft-AzureKubernetesServiceChaosMesh/NetworkChaos-2.1')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat(resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName')), '/', 'providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh')]"
            ],
            "properties": {}
        },
        {
            "type": "Microsoft.ContainerService/managedClusters/providers/targets/capabilities",
            "apiVersion": "2021-09-15-preview",
            "name": "[concat(parameters('clusterName'), '/', 'Microsoft.Chaos/Microsoft-AzureKubernetesServiceChaosMesh/PodChaos-2.1')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat(resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName')), '/', 'providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh')]"
            ],
            "properties": {}
        },
        {
            "type": "Microsoft.ContainerService/managedClusters/providers/targets/capabilities",
            "apiVersion": "2021-09-15-preview",
            "name": "[concat(parameters('clusterName'), '/', 'Microsoft.Chaos/Microsoft-AzureKubernetesServiceChaosMesh/StressChaos-2.1')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat(resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName')), '/', 'providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh')]"
            ],
            "properties": {}
        },
        {
            "type": "Microsoft.ContainerService/managedClusters/providers/targets/capabilities",
            "apiVersion": "2021-09-15-preview",
            "name": "[concat(parameters('clusterName'), '/', 'Microsoft.Chaos/Microsoft-AzureKubernetesServiceChaosMesh/IOChaos-2.1')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat(resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName')), '/', 'providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh')]"
            ],
            "properties": {}
        },
        {
            "type": "Microsoft.ContainerService/managedClusters/providers/targets/capabilities",
            "apiVersion": "2021-09-15-preview",
            "name": "[concat(parameters('clusterName'), '/', 'Microsoft.Chaos/Microsoft-AzureKubernetesServiceChaosMesh/TimeChaos-2.1')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat(resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName')), '/', 'providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh')]"
            ],
            "properties": {}
        },
        {
            "type": "Microsoft.ContainerService/managedClusters/providers/targets/capabilities",
            "apiVersion": "2021-09-15-preview",
            "name": "[concat(parameters('clusterName'), '/', 'Microsoft.Chaos/Microsoft-AzureKubernetesServiceChaosMesh/KernelChaos-2.1')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat(resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName')), '/', 'providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh')]"
            ],
            "properties": {}
        },
        {
            "type": "Microsoft.ContainerService/managedClusters/providers/targets/capabilities",
            "apiVersion": "2021-09-15-preview",
            "name": "[concat(parameters('clusterName'), '/', 'Microsoft.Chaos/Microsoft-AzureKubernetesServiceChaosMesh/DNSChaos-2.1')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat(resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName')), '/', 'providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh')]"
            ],
            "properties": {}
        },
        {
            "type": "Microsoft.ContainerService/managedClusters/providers/targets/capabilities",
            "apiVersion": "2021-09-15-preview",
            "name": "[concat(parameters('clusterName'), '/', 'Microsoft.Chaos/Microsoft-AzureKubernetesServiceChaosMesh/HTTPChaos-2.1')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat(resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName')), '/', 'providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh')]"
            ],
            "properties": {}
        }
    ],
    "outputs": {}
}
TEMPLATE
}

resource "azurerm_resource_group_template_deployment" "onboard-cosmos-chaos" {
  name                = "onboard-cosmos"
  resource_group_name = var.resource_group_name_cosmos
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "resourceName" = {
      value = var.cosmosDbName
    }
  })
  template_content = <<TEMPLATE
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "resourceName": {
      "type": "string",
      "metadata": {
        "description": "The name of the resource being enabled."
      }
    },
    "location": {
        "type": "string",
        "defaultValue": "[resourceGroup().location]",
        "metadata": {
            "description": "Location"
        }
    }
  },
  "variables": {},
  "resources": [
    {
      "type": "Microsoft.DocumentDB/databaseAccounts/providers/targets",
      "apiVersion": "2021-09-15-preview",
      "name": "[concat(parameters('resourceName'), '/', 'Microsoft.Chaos/Microsoft-CosmosDB')]",
      "location": "[parameters('location')]",
      "properties": {}
    },
    {
      "type": "Microsoft.DocumentDB/databaseAccounts/providers/targets/capabilities",
      "apiVersion": "2021-09-15-preview",
      "name": "[concat(parameters('resourceName'), '/', 'Microsoft.Chaos/Microsoft-CosmosDB/Failover-1.0')]",
      "location": "[parameters('location')]",
      "dependsOn": [
        "[concat(resourceId('Microsoft.DocumentDB/databaseAccounts', parameters('resourceName')), '/', 'providers/Microsoft.Chaos/targets/Microsoft-CosmosDB')]"
      ],
      "properties": {}
    }
  ],
  "outputs": {}
}
TEMPLATE
}

resource "azurerm_resource_group_template_deployment" "experiment-k8s-pod-stressor" {
  name                = "experiment-k8s-pod-stressor"
  resource_group_name = var.resource_group_name_chaos
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "experimentName" = {
      value = "k8spodstressor"
    }
    "clusterName" = {
      value = var.clusterName
    },
    "clusterResGroup" = {
      value = var.resource_group_name_k8s
    }
  })
  template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "experimentName": {
      "type": "string",
      "metadata": {
        "description": "A name for the experiment."
      }
    },
    "clusterName": {
        "type": "string"
    },
    "clusterResGroup": {
        "type": "string"
    }
  },
  "functions": [],
  "variables": {},
  "resources": [
    {
      "type": "Microsoft.Chaos/experiments",
      "apiVersion": "2021-09-15-preview",
      "name": "[parameters('experimentName')]",
      "location": "[resourceGroup().location]",
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "identity": {
          "properties": {
            "type": "SystemAssigned"
          }
        },
        "selectors": [
          {
            "id": "Selector1",
            "type": "List",
            "targets": [
              {
                "type": "ChaosTarget",
                "id": "[concat(resourceId(parameters('clusterResGroup'), 'Microsoft.ContainerService/managedClusters', parameters('clusterName')), '/', 'providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh')]"
              }
            ]
          }
        ],
        "startOnCreation": "false",
        "steps": [
            {
                "name": "Step 1",
                "branches": [
                    {
                        "name": "Branch 1",
                        "actions": [
                            {
                                "type": "continuous",
                                "selectorId": "Selector1",
                                "duration": "PT5M",
                                "parameters": [
                                    {
                                        "key": "jsonSpec",
                                        "value": "{\n    \"mode\": \"one\",\n    \"selector\": {\n        \"namespaces\": [\n            \"contactsapp\"\n        ],\n        \"labelSelectors\": {\n            \"application\": \"scmcontacts\",\n            \"service\": \"contactsapi\"\n        }\n    },\n    \"stressors\": {\n        \"cpu\": {\n            \"workers\": 4,\n            \"load\": 50\n        }\n    }\n}"
                                    }
                                ],
                                "name": "urn:csci:microsoft:azureKubernetesServiceChaosMesh:stressChaos/2.1"
                            }
                        ]
                    }
                ]
            }
        ]
      }
    }
  ],
  "outputs": {
  "pricipalId": {
        "type": "string",
        "value": "[reference(resourceId('Microsoft.Chaos/experiments', parameters('experimentName')), '2021-09-15-preview', 'Full').identity.principalId]"
      }
  }
}
TEMPLATE
}

resource "azurerm_resource_group_template_deployment" "experiment-k8s-pod-chaos" {
  name                = "experiment-k8s-pod-chaos"
  resource_group_name = var.resource_group_name_chaos
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "experimentName" = {
      value = "k8spodchaos"
    }
    "clusterName" = {
      value = var.clusterName
    },
    "clusterResGroup" = {
      value = var.resource_group_name_k8s
    }
  })
  template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "experimentName": {
      "type": "string",
      "metadata": {
        "description": "A name for the experiment."
      }
    },
    "clusterName": {
        "type": "string"
    },
    "clusterResGroup": {
        "type": "string"
    }
  },
  "functions": [],
  "variables": {},
  "resources": [
    {
      "type": "Microsoft.Chaos/experiments",
      "apiVersion": "2021-09-15-preview",
      "name": "[parameters('experimentName')]",
      "location": "[resourceGroup().location]",
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "identity": {
          "properties": {
            "type": "SystemAssigned"
          }
        },
        "selectors": [
          {
            "id": "Selector1",
            "type": "List",
            "targets": [
              {
                "type": "ChaosTarget",
                "id": "[concat(resourceId(parameters('clusterResGroup'), 'Microsoft.ContainerService/managedClusters', parameters('clusterName')), '/', 'providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh')]"
              }
            ]
          }
        ],
        "startOnCreation": "false",
        "steps": [
            {
                "name": "Step 1",
                "branches": [
                    {
                        "name": "Branch 1",
                        "actions": [
                            {
                                "type": "continuous",
                                "selectorId": "Selector1",
                                "duration": "PT3M",
                                "parameters": [
                                    {
                                        "key": "jsonSpec",
                                        "value": "{\n    \"action\": \"pod-failure\",\n    \"mode\": \"one\",\n    \"duration\": \"120s\",\n    \"selector\": {\n        \"namespaces\": [\n            \"contactsapp\"\n        ],\n        \"labelSelectors\": {\n            \"application\": \"scmcontacts\",\n            \"service\": \"contactsapi\"\n        }\n    }\n}"
                                    }
                                ],
                                "name": "urn:csci:microsoft:azureKubernetesServiceChaosMesh:podChaos/2.1"
                            }
                        ]
                    }
                ]
            }
        ]
      }
    }
  ],
  "outputs": {
    "pricipalId": {
        "type": "string",
        "value": "[reference(resourceId('Microsoft.Chaos/experiments', parameters('experimentName')), '2021-09-15-preview', 'Full').identity.principalId]"
      }
  }
}
TEMPLATE
}

resource "azurerm_resource_group_template_deployment" "experiment-cdb-chaos" {
  name                = "experiment-cdb-chaos"
  resource_group_name = var.resource_group_name_chaos
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "experimentName" = {
      value = "cdbchaos"
    }
    "cosmosDbName" = {
      value = var.cosmosDbName
    },
    "cosmosResGroup" = {
      value = var.resource_group_name_cosmos
    }
    "cosmosFailoverRegion" = {
      value = var.resource_group_name_cosmos
    }
  })
  template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "experimentName": {
      "type": "string",
      "metadata": {
        "description": "A name for the experiment."
      }
    },
    "cosmosDbName": {
        "type": "string"
    },
    "cosmosResGroup": {
        "type": "string"
    },
    "cosmosFailoverRegion": {
        "type": "string"
    }
  },
  "functions": [],
  "variables": {},
  "resources": [
    {
      "type": "Microsoft.Chaos/experiments",
      "apiVersion": "2021-09-15-preview",
      "name": "[parameters('experimentName')]",
      "location": "[resourceGroup().location]",
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "identity": {
          "properties": {
            "type": "SystemAssigned"
          }
        },
        "selectors": [
          {
            "id": "Selector1",
            "type": "List",
            "targets": [
              {
                "type": "ChaosTarget",
                "id": "[concat(resourceId(parameters('cosmosResGroup'), 'Microsoft.DocumentDB/databaseAccounts', parameters('cosmosDbName')), '/', 'providers/Microsoft.Chaos/targets/Microsoft-CosmosDB')]"
              }
            ]
          }
        ],
        "startOnCreation": "false",
        "steps": [
            {
                "name": "Step 1",
                "branches": [
                    {
                        "name": "Branch 1",
                        "actions": [
                            {
                                "type": "continuous",
                                "selectorId": "Selector1",
                                "duration": "PT10M",
                                "parameters": [
                                    {
                                        "key": "readRegion",
                                        "value": "North Europe"
                                    }
                                ],
                                "name": "urn:csci:microsoft:cosmosDB:failover/1.0"
                            }
                        ]
                    }
                ]
            }
        ]
      }
    }
  ],
  "outputs": {
    "pricipalId": {
        "type": "string",
        "value": "[reference(resourceId('Microsoft.Chaos/experiments', parameters('experimentName')), '2021-09-15-preview', 'Full').identity.principalId]"
      }
  }
}
TEMPLATE
}


resource "azurerm_role_assignment" "podchaos-cluster-admin" {
  scope                = var.clusterId
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.experiment-k8s-pod-chaos.output_content).pricipalId.value
}

resource "azurerm_role_assignment" "podstressor-cluster-admin" {
  scope                = var.clusterId
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.experiment-k8s-pod-stressor.output_content).pricipalId.value
}

resource "azurerm_role_assignment" "chaos-cosmos-admin" {
  scope                = var.cosmosDbId
  role_definition_name = "Cosmos DB Operator"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.experiment-cdb-chaos.output_content).pricipalId.value
}

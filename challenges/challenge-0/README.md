# Challenge 0 - Setup the environment

## Introduction

To introduce you the "world of chaos engineering", will be using a typical cloud-native application that runs on top of an Azure-hosted Kubernetes cluster as our "target". The application is called "Simple Contacts Management" and gives a user the ability to manage contacts and visitreports, a very tiny CRM, so to say.

It runs on several Azure and in-cluster services like SQL Server, CosmosDB (for NoSql data), Azure Search (for providing full-text search capabilities) and Azure Storage Accounts. It also uses Azure Service Bus to decouple services from each other. None of the services directly calls another one to retrieve information from it. 

If information needs to be exchanged, messages are put into the Service Bus - either on a queue or a topic (to be able to have multiple subscribers). So, e.g., if the search index for contacts needs to be updated, the corresponding service (`Contacts API`) does not call the Azure service directly. It will put a message on the Azure Service Bus that the contact has been updated. In the background, a worker "function" listens on that topic, picks-up the message and updates the search index. That's how the application works in general.

The architecture - from a 10.000ft view - looks like that:

![architecture](./img/aks-architecture.png)

The application also consists of a frontend that has been written in VueJS. To give you a brief overview, here are some views:

![home](./img/app_home.png)
![contacts](./img/app_contacts.png)
![stats](./img/app_stats.png)

## Setup the Azure Cloud Shell

...

## Create the Kubernetes Cluster

...

## Create the infrastructure and deploy the application

...

## Smoke Test

...

## Monitoring

...
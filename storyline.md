# Chaos Engineering on Azure AKS

# Intro (slides)

 * Introduction of the people and the companies
 * Introduction of the agenda and the workshop rules (split participants into groups, info about technical video call setup)
 * Introduction of the demo application and the technical basics for the workshop

# Challenge #1: Install AKS platform & application

In this challenge we create the basic setup for our chaos engineering experiments.

Goals:

* Introducing the Azure Cloud Shell
* Learn how to create an AKS cluster with Azure CLI
* Learn how to setup our demo application with Terraform
* Learn how to us ApplicationInsights and Distributed Tracing

# Challenge #2: Chaos Engineering "hello world"

In this challenge we want to learn the basics of chaos engineering with two simple examples. We start in gameday mode and automate the experiments with the ChaosToolkit.

Goals:

* Learn process: Steady State -> Hypothesis -> Experiment -> Verify -> Learn & Fix
* Get in touch with Gameplay Modus
* Get in touch with [ChaosToolkit](https://chaostoolkit.org/) scripting and execution

## Practice #1: Application failure

* We simulate the failure of one pod instance of the frontend service. We do this by killing the one frontend pod.
* Do this in manual gameplay mode. Call the application in the browser. Observe the steady state in the browser and in the monitoring tools.
  * Kill pod with `kubectl`
  * Is the application still accessible? What is the expected error behavior and does it occur?
* How to fix the temporary total application failure when your frontend pod fails? _Solution: Run the frontend with multiple instances._
* Repeat the experiment. Does the total failure still occur?
* Write down the experiment in a ChaosToolkit script and test the script in your Azure Cloud Shell

## Practice #2: Loss of data

* Create some contacts via the web UI of the demo application
* Kill now the SQL Server Pod instance
* What happens in this experiment? _Because there is no external storage attached, the DB pod data will be lost and the new pod will start with an empty database._
* Fix the problem (Azure SQL DB or Persistent Volume).
* Repeat the experiment. Does the total failure still occur?
* Write down the experiment in a Chaos Toolkit script and test the script in your Azure Cloud Shell. _Open issue: How can we validate the persistent data after pod restart?_

# Challenge #3: Spread your application over the whole cluster

Goals:

* Get in touch with Chaos Toolkit Azure Extention
* Get in touch with Kubernetes Node affinity / anti-affinity

## Practice

* Check on which nodes the pod instances of the frontend service are running. 
* If the two instances are running on different nodes, the Kubernetes scheduler has worked well and distributed your app well.
* If they are running on one node, a failure of that node will again lead to a temporary total application failure. 

# Challenge #4: Stability also in case of network troubles

Goals:

* Get in touch with [Chaos Mesh](https://github.com/chaos-mesh/chaos-mesh)
* Learn how the demo application reacts to network problems and which tricks there are for a more resilient application.

## Practice #1

* [Setup Chaos Mesh](https://chaos-mesh.org/docs/user_guides/installation) in your AKS cluster.
* Slow down the outgoing network traffic from the Contact service to the SQL database
* We should set the connection pool very aggressively at first. Goal: If we slow down the network, connection timeouts should occur very quickly and the service should deliver HTTP 500.
* Fix the problem: Configure the connection pool less aggressively, but also not unnecessarily soft (e.g. socketTimeout).
* Repeat the experiment

Alternative: We slow down the network between Search Service and Azure Search Index

## Practice #2

* We experiment with asynchronous communication between resource service and search indexer func.
* Slow down the outgoing network traffic from the Resource service to Service Bus
* We should set the connectivity conficuration very agressivly (very low timeouts, not retries)
* Fix the problem: Configure the Service Bus Client less aggressively and with retries.

# Challenge #5 (optional): 

Goals:

* Increased reliability with availability zones
* Understand the behavior of your platform and application when an availability zone fails.

# Practice

* Add a second node pool in your AKS cluster
* Distribute the pods of your application uncontrolled over the node pools
* Stop all nodes from a node pool. How long does it take the platform to detect the failure and shift all the application's pods to the other node pool? Are there any failures?
* Add instances in both node pools and distribute your application's pods so that the failure of an availability zone has no impact on your application's availability.

Open issue: How can we control the node pools and validate the availability of the complete application? Manually and via mini-load test?

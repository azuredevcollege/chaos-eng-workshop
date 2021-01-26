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

 In this challenge we want to learn the basics of chaos engineering with two simple examples. We start in gameday mode and automate the experiments with the Chaos Toolkit.

 Goals:

* Learn process: Steady State -> Hypothesis -> Experiment -> Verify -> Learn & Fix
* Get in touch with Gameplay Modus
* Get in touch with Chaos Toolkit scripting and execution

* Example #1: Application failure
  * We simulate the failure of one pod instance of the frontend service. We do this by killing the one frontend pod.
    * Do this in manual gameplay mode. Call the application in the browser. Observe the steady state in the browser and in the monitoring tools. 
    * Kill pod with `kubectl`
    * Is the application still accessible? What is the expected error behavior and does it occur?
  * How to fix the total application failure when one pod fails? Solution: Run the frontend with multiple instances.
  * Repeat the experiment. Does the total failure still occur?
  * Write down the experiment in a Chaos Toolkit script and test the script in your Azure Cloud Shell

* Example #2: Loss of data
  * Create some contacts via the web UI of the demo application
  * Kille now the SQL Server Pod instance
  * What happens in this experiment? _Because there is no external storage attached, the DB pod data will be lost and the new pod will start with an empty database._
  * Fix the problem.
  * Repeat the experiment. Does the total failure still occur?
  * Write down the experiment in a Chaos Toolkit script and test the script in your Azure Cloud Shell. _Open issue: How can we validate the persistent data after pod restart?_

  # Challenge #3: Spread your application over the whole cluster

  Goals:

  * Get in touch with Chaos Toolkit Azure Exteention
  * Get in touch with Kubernetes Node affinity / anit-affinity

  # Challenge #4: Network issues

  Goals:

   * Get in touch with Chaos Mesh
   * 
# Challenge 4 (Bonus) - Increasing reliability using availability zones

## Introduction 

In this challenge, we will simulate a larger failure of our cluster nodes. What if the data center, in which your nodes are running, completely fails? We setup our clusters in challenge #0 only in one data center. Cloud provider introduced the concept of availability zones. An availability zone is a isolated data center in a region to increase reliability of a service region. When a service is distributed over multiple availability zone in a region, even when one availability zone is failing, the service is still accessible using a different availability zone. For more information about availability zones in Azure, read this [document](https://docs.microsoft.com/en-us/azure/availability-zones/az-overview).

We will answer the following questions during this challenge:
- What happens to our application, when one availability zone is failing? 
- How do we make the application more resilient to availability zone failures?

:warning: *Note*: this challenge is more open-ended, so we will not provide a step-by-step solution but rather some pointers how to create the experiment and increase the reliability of the SCM application using availability zones.


## Experiment with availability zone failure

How could we test a failure of one specific availability zone? We can re-use the stop node experiment from challenge #2. What do you need to change here, to kill all nodes of one availability zone?

First, where do you see to which zone your node belongs? Go to the Azure Portal and to the *Virtual Machine Scale Set* of the cluster you provisioned. There under location, you can see the zone.
This property will help us identify to which availability zone a node belongs. 

Second, do you remember the `instance_criteria` of the *stop_vmss* action? We always only selected one instance but you can actually select multiple instances using a criteria that fits multiple instances. We need to somehow change the instance criteria to select all instances of an availability zone. Check out the Azure CLI command `az vmss list-instances` to see which property you could use as `instance_criteria`. It has something to do with availability zones... 

Finally, modify the experiment so that you take the availability zone to kill the nodes in as input and change the `instance_criteria` to use the property you previously found with the input availability zone. Modify both the action and rollback definition! 

The [documentation of the chaostoolkit Azure plugin](https://docs.chaostoolkit.org/drivers/azure/) (if the link is broken try the [archived version](https://web.archive.org/web/20201202114252/https://docs.chaostoolkit.org/drivers/azure/)) can help with defining the experiment and expressing the instance criteria. If you can understand Python code, it also helps to directly check [the code behind the actions](https://github.com/chaostoolkit-incubator/chaostoolkit-azure/blob/master/chaosazure/vmss/actions.py).

If you are finished, run the experiment in the same way as in challenge #2.

What is the result of the experiment? 
The expectation is that the experiment fails, because all the nodes of your cluster are stopped.

What do we need to do to solve the issue and make the experiment succeed?

If you are stuck, we added a sample chaos experiment in `samples/stop-node-az.yaml`.
## Spreading the application over multiple availability zones

### Deploy a second node pool with nodes in multiple availability zones

We need to create nodes in all availability zones of our selected region so that even when one availability zone fails, our applications are still working.

The documentation of Azure helps you here how you can modify your cluster to use nodepools with nodes in multiple availability zones. 
Deploy a node pool using the Azure CLI and spread your nodes over all availability zones. 
These docs can help:
- https://docs.microsoft.com/en-us/azure/aks/availability-zones
- https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools

### Modify the Pod Anti-Affinity rules to create replicas in all availability zones

Simply adding nodes in all availability zones will not help. Each service of the application also needs to have one replica running in each availability zone. 

Read this [document about Pod Anti-Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity) and modify the deployment manifests of each service under `apps/manifests` so that one pod must run in each availability zone. You must also increase the number of replicas to the amount of availability zones your cluster uses.

### Re-run the experiment

After deploying the previous changes, you should see:
- at least one nodes in each availability zone
- at least one pod per availability zone for all services

Now, re-run the experiment. 

With the improvements you did, it should not fail anymore :sunglasses:.
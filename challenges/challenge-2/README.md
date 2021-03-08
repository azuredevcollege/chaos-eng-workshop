# Challenge 2 - Spread your application over the whole cluster

In this section, we will get in touch with the Azure Extension of Chaos Toolkit. With this extension, we can create chaos on the Kubernetes nodes by directly interacting with the Azure resources which power the cluster. 

We will answer the following questions during the challenge:
- What happens to our application, when one node is done? 
- How do we make the application more resilient to node failures?

## Prerequisites

### Create a service principal to interact with the Azure API

The Azure extension of chaos-toolkit interacts with the Azure API using a service principal. We need to create it first and store the credentials in a file which we will be read by chaos-toolkit.

Run the following command to create the service principal:
```bash
az ad sp create-for-rbac --sdk-auth > credentials.json
```

Before executing a command with chaos-toolkit, reference the credentials like this:
```bash
export AZURE_AUTH_LOCATION=credentials.json
```

### Install Azure extension for chaos-toolkit

To install the Azure extension, run the following commands:
```bash
pip install -U chaostoolkit-azure

# Due to chaostoolkit-azure no pinning old library versions that depend on, we need to install them manually:
pip install azure-mgmt-resourcegraph==2.0.0
pip install azure.mgmt.compute==7.0.0
```

## Pod distribution over nodes
In the previous challenge, we increased the replica amount of the frontend deployment to 2 replicas. This makes our frontend highly available and protects us from sudden pod failures. If one pod fails, there will always be a at least one more to answer requests.

But what about node failures? If all pods of multiple applications or all pods of an application are on the same node and that node fails, we have a outage of our applications. While Kubernetes will quickly spin up new pods when a node is suddenly removed, the application startup will determine our downtime. 

It is important to know how the pods are distributed over the cluster. Check for all services on which nodes the pod instances are running.  

You can do this either by checking the Kubernetes dashboard inside the Azure Portal or by using kubectl. Let's try this out with kubectl:

You can run `kubectl get nodes` to see how many nodes are currently running in the cluster.
For example:
```bash
$ kubectl get nodes
NAME                                STATUS   ROLES   AGE   VERSION
aks-nodepool1-36421985-vmss000000   Ready    agent   27d   v1.18.14
aks-nodepool1-36421985-vmss000009   Ready    agent   16d   v1.18.14
aks-nodepool1-36421985-vmss00000a   Ready    agent   16d   v1.18.14
```

Let's see how the different application pods  are distributed over the cluster. We use the parameter `-o wide` in `kubectl get pods` to display the node on which the pod is running:
```bash
NAME                                             READY   STATUS    RESTARTS   AGE     IP             NODE     NOMINATED NODE   READINESS GATES
ca-deploy-7d6855964c-sn7wm                       1/1     Running   0          3d19h   10.244.7.18    aks-nodepool1-36421985-vmss00000a   <none>           <none>
frontend-deploy-5d85979b7b-m4cjx                 1/1     Running   0          16d     10.244.6.6     aks-nodepool1-36421985-vmss000009   <none>           <none>
mssql-deployment-5998699cd8-9rpx5                1/1     Running   0          16d     10.244.6.13    aks-nodepool1-36421985-vmss000009   <none>           <none>
resources-deploy-7f5f968587-ql2bg                1/1     Running   0          3d19h   10.244.7.19    aks-nodepool1-36421985-vmss00000a   <none>           <none>
resources-function-deploy-58744cb66-tlvrh        1/1     Running   0          3d19h   10.244.7.16    aks-nodepool1-36421985-vmss00000a   <none>           <none>
search-deploy-88bd76564-6s9dh                    1/1     Running   0          3d19h   10.244.2.223   aks-nodepool1-36421985-vmss000000   <none>           <none>
search-deploy-88bd76564-744xn                    1/1     Running   0          3d19h   10.244.2.222   aks-nodepool1-36421985-vmss000000   <none>           <none>
search-function-deploy-84b4b6bc84-sdxdr          1/1     Running   0          3d19h   10.244.7.17    aks-nodepool1-36421985-vmss00000a   <none>           <none>
textanalytics-function-deploy-6bc56f6b8c-jxqsk   1/1     Running   0          3d19h   10.244.7.20    aks-nodepool1-36421985-vmss00000a   <none>           <none>
visitreports-deploy-5fc8bf9cf5-gfv9r             1/1     Running   1          16d     10.244.6.8     aks-nodepool1-36421985-vmss000009   <none>           <none>
```
If the two instances are running on different nodes, the Kubernetes scheduler has worked well and distributed your app well.
If they are running on one node, a failure of that node will again lead to a temporary total application failure. 
In this case both replicas are running on two different nodes.


## Experiment with node failures
We will now try out what happens with our application when we stop one of the nodes of our cluster. 

### Stop one node manually
Let's first do this manually.

First select the resource group of your AKS cluster. You can find it by selecting *Resource groups* in the Azure Portal.
_TODO: add Images from Azure Portal_
Select the resource groups with the name `MC_<resource-group of your cluster>_<cluster_name>_<location>`. This contains the underlying Azure resources of your AKS cluster.

Now, select the Virtual machine scale set of your cluster. There should be only one in this resource group.

Select *Instances* in the left sidebar to view all instances of the scale set. 

Finally, you can select one of the instances to stop. 
When you stopped one, monitor your application health status and the node status.

You can check the nodes of your cluster by using the kubectl command from before `kubectl get nodes`
For example:
```bash
$ kubectl get nodes
NAME                                STATUS   ROLES   AGE   VERSION
aks-nodepool1-36421985-vmss000000   Ready    agent   27d   v1.18.14
aks-nodepool1-36421985-vmss000009   Ready    agent   16d   v1.18.14
aks-nodepool1-36421985-vmss00000a   Ready    agent   16d   v1.18.14
```
Tip: add a `watch` in front of the command to see live updates of your nodes. 

At some point one of the nodes is *NotReady*. How long does it take, until Kubernetes registers this? How does this influence our monitoring or testing of the Kubernetes health state?

Check if your application still works normally. You can also view if enough pods are still alive using `kubectl get pods` in the namespace of the application. If your application is down - how long does it take to recover? 

Take these learnings into account, when creating a chaos experiment in the next part of the challenge.
### Create a chaos experiment using chaostoolkit

To retrieve the necessary names for the chaos experiment, execute the following commands:
```bash
NODE_RESGROUP=$(az aks show -n <CLUSTER_NAME> -g <CLUSTER_RES_GROUP> --query "nodeResourceGroup" -o tsv)
VMSS_NAME=$(az vmss list -g $NODE_RESGROUP --query [0].name -o tsv)
VMSS_INSTANCE0=$(az vmss list-instances -n $VMSS_NAME -g $NODE_RESGROUP --query [0].name -o tsv)
```

_Open Issue: Previous challenge solution was multi-replicas for frontend service. This means most likely the frontend service is distributed on two nodes. If we keep the replicas of other services to one, the story could be inter pod anti affinity: Even though frontend service is running HA, other services still run on the same node that goes down with only one replica. Can we test the application in a way to check if frontend works with backend correctly?_

## Spread pods over multiple nodes
_Increase replicas for all applications_ 
_Create Inter Pod AntiAffinity with frontend and other applications that have heavy dependencies on each other. Should not be co-located on the same node._ 

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
In the previous challenge, we increased the replica amount of each deployment to at least 2. This makes all applications highly available and protects us from sudden pod failures. If one pod fails, there will always be a at least one more to answer requests.

But what about node failures? If both pods of an application are on the same node and that node fails, we have a problem. While Kubernetes will quickly spin up new pods when a node is suddenly removed, the application startup will be our downtime. 

It is important to know how the pods are distributed over the cluster. Check for the frontend service on which nodes the pod instances are running.  

You can do this either by checking the Kubernetes dashboard inside the Azure Portal or by using kubectl. Kubectl is the preferred way:

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
_Use stop node experiment from talk as base. Do not select a specific node, but choose a random one from VMSS_   
_Open Issue: Previous challenge solution was multi-replicas for frontend service. This means most likely the frontend service is distributed on two nodes. If we keep the replicas of other services to one, the story could be inter pod anti affinity: Even though frontend service is running HA, other services still run on the same node that goes down with only one replica. Can we test the application in a way to check if frontend works with backend correctly?_

## Spread pods over multiple nodes
_Create Inter Pod AntiAffinity with frontend and other applications that heavy dependencies on each other. Should not be co-located on the same node._ 
_Increase replicas for all applications_ 
# chaos-eng-workshop

## Create ResourceGroup

```Shell
$ az group create -n <ResourceGroupName> -l westeurope
```

## Create Cluster

```Shell
$ az aks create -g <ResourceGroupName> -n <ClusterName> --node-count 3 --enable-managed-identity --node-vm-size standard_b2s --generate-ssh-keys
```

## Get-Credentials

```Shell
$ az aks get-credentials -g <ResourceGroupName> -n <ClusterName>
```

## Deploy the application

Switch to directory _terraform_ and run following commands:

```Shell
$ terraform init 
$ terraform apply -var="prefix=<yourprefix>" -var="location=westeurope"
# Answer with 'yes' when asked, that the changes will be applied.
```


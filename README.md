# chaos-eng-workshop

## Create ResourceGroup

```Shell
$ az group create -n <ResourceGroupName> -l westeurope
```

## Create Cluster

```Shell
$ az aks create -g <ResourceGroupName> -n <ClusterName> --node-count 3 --enable-managed-identity --node-vm-size standard_b2s --generate-ssh-keys --zones 1 2 3
```

## Get-Credentials

```Shell
$ az aks get-credentials -g <ResourceGroupName> -n <ClusterName>
```

## Deploy the application

Switch to directory _terraform_ and run following commands:

```Shell
$ terraform init 
$ terraform apply -var="prefix=<yourprefix>" -var="location=westeurope" -var="aks_resource_group_name=<ResourceGroupName>" -var="akscluster=<ClusterName>"
# Answer with 'yes' when asked, that the changes will be applied.
```

## Readiness / Liveness Probes

Each service comes with a `/health/live` and `/health/ready` endpoint. The liveness endpoint returns `200` as soon as the corresponding service is up and running. The readiness endpoint returns a `503` by default for 15 sec, after that timespan `200`. That delay value can be adjusted by an environment variable:

- Contacts / Resources / Search API: `ReadinessDelaySeconds` (e.g. `5`)
- VisitReports API: `READINESSDELAYSECONDS`

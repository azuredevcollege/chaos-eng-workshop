#!/usr/bin/env bash

kubectl create secret generic basic-auth --from-file=auth -n chaos-testing
kubectl get secret basic-auth -o yaml -n chaos-testing
kubectl apply -f chaosmesh-dashboard-ingress.yaml 
#!/bin/bash
echo "Installing Component for Prometheus"

kubectl apply -f components-prometheus.yaml


echo "Add repo to Prometheus"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
--------------------------------------------------------------------------------
echo "Installing Prometheus using helm "

helm install prometheus \
 prometheus-community/kube-prometheus-stack \
 --namespace monitoring \
 --create-namespace \
 --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"

 echo "Installiton Complete"




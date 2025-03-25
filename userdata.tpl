#!/bin/bash

# Update & install dependencies
sudo apt update -y
sudo apt upgrade -y

# Install k3s
curl -sfL https://get.k3s.io | sh -

# Set KUBECONFIG environment variable
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Change kubeconfig permission to avoid sudo issues
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Check cluster status
kubectl get nodes

# Install Helm (for monitoring tools)
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Add Prometheus & Grafana Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/prometheus

# Install Grafana
helm install grafana grafana/grafana --set adminPassword='admin'

# Done!

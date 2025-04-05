#!/bin/bash

# Update the system
apt-get update -y
apt-get upgrade -y

# Install required tools
apt-get install -y curl unzip apt-transport-https software-properties-common

# Install k3s
curl -sfL https://get.k3s.io | sh -

# Wait for kubeconfig file to be created
while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
  echo "Waiting for k3s.yaml to be created..."
  sleep 2
done

# Fix permissions on kubeconfig
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Set KUBECONFIG for current session
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Also set it system-wide for all future logins
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /etc/profile

# Optional: wait a bit to make sure cluster is ready
sleep 30

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

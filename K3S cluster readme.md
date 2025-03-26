# K3s Kubernetes Cluster on AWS (Free Tier)

## Overview

This project deploys a lightweight Kubernetes cluster using k3s on an AWS EC2 Ubuntu instance (t2.micro, Free Tier). Monitoring is implemented using Prometheus and Grafana via Helm.

---

## 🏗️ Infrastructure Overview

- ✅ 1 EC2 instance (Ubuntu 20.04 LTS, t2.micro, public subnet)
- ✅ k3s (single-node cluster)
- ✅ Helm installed for package management
- ✅ Monitoring: Prometheus + Grafana
- ✅ GitHub Actions for Terraform CI/CD

---

## 🔧 Deployment Steps

### 1. Launch EC2 using Terraform

Ubuntu AMI filtered by Canonical owner ID:

```hcl
owners = ["099720109477"]
values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
```

### 2. Install k3s (via user_data script)

```bash
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
```

### 3. Export kubeconfig (important)

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

> This variable tells `kubectl` to use the k3s-generated config file at `/etc/rancher/k3s/k3s.yaml` instead of the default `~/.kube/config`. This is essential because `kubectl` wouldn’t otherwise know how to connect to the cluster.

### 4. Verify cluster

```bash
kubectl get nodes
```

---

## 📊 Monitoring Setup (Prometheus + Grafana)

### 1. Install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

### 2. Add and install Prometheus & Grafana

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/prometheus
helm install grafana grafana/grafana --set adminPassword='admin'
```

### 3. Access Grafana dashboard

```bash
kubectl port-forward svc/grafana 3000:80
```

Then open in your browser:

```txt
http://localhost:3000
```

Login:

- Username: `admin`
- Password: `admin`

### 4. (Optional) Add Prometheus as a Data Source

If not auto-detected by Grafana:

- Go to ⚙️ > Data Sources > Add New
- Select Prometheus
- URL: `http://prometheus-server`

---

## ✅ Result

- Kubernetes cluster running and reachable.
- Simple pod deployed successfully:

```bash
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
```

- Monitoring dashboard up and running.
- All setup automated via Terraform + cloud-init (`user_data`).

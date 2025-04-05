
    #!/bin/bash
    # Update system and install basic tools
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt-get install -y curl unzip apt-transport-https

    # Install k3s
    curl -sfL https://get.k3s.io | sh -
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

    # Add Jenkins Helm repo and update
    helm repo add jenkins https://charts.jenkins.io
    helm repo update

    # Wait until Kubernetes is ready
    until kubectl get nodes; do sleep 5; done
    sleep 30

    # Create namespace for Jenkins
    kubectl create namespace jenkins

    # Install Jenkins with LoadBalancer service
    helm install jenkins jenkins/jenkins \
      --namespace jenkins \
      --set controller.serviceType=LoadBalancer
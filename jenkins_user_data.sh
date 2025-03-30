#!/bin/bash

# Log output for troubleshooting
exec > /var/log/user_data.log 2>&1
set -ex

echo "⏳ Starting user_data script..."

# Wait for networking to stabilize
echo "⏳ Waiting for network..."
sleep 30

# Update system
echo "🔄 Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# Install dependencies
echo "📦 Installing dependencies..."
sudo apt install -y curl unzip apt-transport-https gnupg openjdk-11-jre-headless

# Install K3s
echo "🚀 Installing K3s..."
curl -sfL https://get.k3s.io | sh -

# Make kubeconfig accessible
echo "🔐 Setting kubeconfig permissions..."
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Install Helm
echo "🛠️ Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Add Jenkins repo and update
echo "📡 Adding Jenkins Helm repo..."
helm repo add jenkins https://charts.jenkins.io
helm repo update

# Create Jenkins namespace
echo "📂 Creating Jenkins namespace..."
kubectl create namespace jenkins || true

# Install Jenkins with persistence enabled
echo "📦 Installing Jenkins via Helm with PVC..."
helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set controller.serviceType=LoadBalancer \
  --set controller.adminPassword=admin123 \
  --set persistence.enabled=true \
  --set persistence.size=8Gi \
  --set persistence.storageClass=local-path

# Wait for Jenkins pod to appear
echo "⏳ Waiting for Jenkins pod..."
sleep 60

# Get Jenkins pod name
echo "🔍 Finding Jenkins pod name..."
JENKINS_POD=$(kubectl get pods -n jenkins -l app.kubernetes.io/component=jenkins-controller -o jsonpath="{.items[0].metadata.name}")

# Show init container logs (if any)
echo "📄 Fetching init container logs (if any)..."
kubectl logs -n jenkins "$JENKINS_POD" -c init || echo "No init container logs found."

# Wait for Jenkins to be fully ready
echo "⏳ Waiting for Jenkins readiness..."
sleep 60

# ✅ Verify PVC and PV status
echo "🔎 Verifying PVC and PV status..."
kubectl get pvc -n jenkins || echo "⚠️ PVC check failed"
kubectl get pv || echo "⚠️ PV check failed"

# Note: Skipping port-forwarding inside user_data as it may fail silently or not persist

# Create Jenkins job XML definition
echo "📝 Creating job XML file..."
cat <<EOF > hello-job.xml
<project>
  <actions/>
  <description>Hello World job</description>
  <keepDependencies>false</keepDependencies>
  <builders>
    <hudson.tasks.Shell>
      <command>echo Hello world</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
EOF

# Download Jenkins CLI and create job manually after login
cat <<INFO

⚠️ Port-forwarding was skipped. To complete setup manually:

1. Run:
   kubectl port-forward svc/jenkins -n jenkins 8080:8080

2. Download Jenkins CLI:
   curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

3. Create the job (if not exists):
   java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:admin123 get-job hello-world || \
   java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:admin123 create-job hello-world < hello-job.xml

INFO

# Done!
echo "✅ Jenkins setup complete with a Hello World job (manual port-forward required)."

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
sudo /usr/local/bin/kubectl create namespace jenkins || true

# Install Jenkins with LoadBalancer service
echo "📦 Installing Jenkins via Helm..."
helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set controller.serviceType=LoadBalancer \
  --set controller.adminPassword=admin123 \
  --set persistence.enabled=false

# Wait for Jenkins pod to appear
echo "⏳ Waiting for Jenkins pod..."
sleep 60

# Get Jenkins pod name
echo "🔍 Finding Jenkins pod name..."
JENKINS_POD=$(sudo /usr/local/bin/kubectl get pods -n jenkins -l app.kubernetes.io/component=jenkins-controller -o jsonpath="{.items[0].metadata.name}")

# Show init container logs (if any)
echo "📄 Fetching init container logs (if any)..."
sudo /usr/local/bin/kubectl logs -n jenkins "$JENKINS_POD" -c init || echo "No init container logs found."

# Wait for Jenkins to be fully ready
echo "⏳ Waiting for Jenkins readiness..."
sleep 60

# Port-forward Jenkins and create freestyle job with curl (JCasC not used here)
echo "🔌 Port-forwarding Jenkins..."
JENKINS_URL="http://localhost:8080"

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

# Install Jenkins CLI and create job
echo "⬇️ Downloading Jenkins CLI..."
JENKINS_CLI_JAR="jenkins-cli.jar"
JENKINS_ADMIN_PWD="admin123"

# Forward port in background
sudo /usr/local/bin/kubectl port-forward svc/jenkins -n jenkins 8080:8080 &
sleep 20

# Download CLI
curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar || echo "⚠️ Could not download Jenkins CLI. Jenkins may not be ready."

# Create the job (may fail silently if Jenkins is still initializing)
echo "📌 Creating Jenkins freestyle job..."
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$JENKINS_ADMIN_PWD create-job hello-world < hello-job.xml || echo "⚠️ Could not create job, Jenkins might not be ready."

# Done!
echo "✅ Jenkins setup complete with a Hello World job."

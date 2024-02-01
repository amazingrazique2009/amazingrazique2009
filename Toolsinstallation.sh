#!/bin/bash

# Function to handle errors
handle_error() {
  echo "Error occurred during installation. Exiting..."
  exit 1
}

# Function to print success message
print_success() {
  echo "Installation successful: $1"
}

# Trap errors and call the handle_error function
trap 'handle_error' ERR

# Install Python
sudo yum install -y python3 || handle_error
print_success "Python"

# Install AWS CLI
curl -o awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" || handle_error
sudo yum install -y unzip || handle_error
unzip awscliv2.zip || handle_error
sudo ./aws/install || handle_error
print_success "AWS CLI"

# Install Java
sudo yum install -y java || handle_error
print_success "Java"

# Install Maven
sudo mkdir -p /opt/ || handle_error
sudo wget 'http://mirrors.estointernet.in/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz' -P /opt/ || handle_error
sudo tar xvzf /opt/apache-maven-3.6.3-bin.tar.gz -C /opt/ || handle_error
sudo tee /etc/profile.d/maven.sh <<EOF
export MAVEN_HOME=/opt/apache-maven-3.6.3
export PATH=\$PATH:\$MAVEN_HOME/bin
EOF
source /etc/profile.d/maven.sh || handle_error
print_success "Maven"

# Install Jenkins
sudo yum update -y || handle_error
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat/jenkins.repo || handle_error
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key || handle_error
sudo yum install -y jenkins || handle_error
sudo systemctl daemon-reload || handle_error
sudo systemctl start jenkins || handle_error
sudo systemctl enable jenkins || handle_error
sudo systemctl status jenkins || handle_error
print_success "Jenkins"

# Install Docker
sudo yum install -y docker || handle_error
sudo usermod -aG docker jenkins || handle_error
sudo systemctl start docker || handle_error
sudo systemctl enable docker || handle_error
print_success "Docker"

# Install Kubectl manually
curl -o kubectl "https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl" || handle_error
chmod +x ./kubectl || handle_error
mkdir -p $HOME/bin || handle_error
cp ./kubectl $HOME/bin/kubectl || handle_error
export PATH=$HOME/bin:$PATH || handle_error
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc || handle_error
source ~/.bashrc || handle_error
kubectl version --short --client || handle_error
print_success "Kubectl"

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp || handle_error
sudo mv /tmp/eksctl /usr/bin || handle_error
eksctl version || handle_error
print_success "eksctl"

# Install Node/NPM
curl -sL https://rpm.nodesource.com/setup_18.x | sudo -E bash - || handle_error
sudo yum install -y nodejs || handle_error
node --version || handle_error
npm --version || handle_error
print_success "Node/NPM"

echo "All installations completed successfully."

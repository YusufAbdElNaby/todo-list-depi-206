#!/bin/bash

# Update package manager repositories
sudo apt-get update

# Install necessary dependencies
sudo apt-get install -y wget apt-transport-https gnupg lsb-release

# Download and add Trivy's GPG key
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

# Add the Trivy repository to Apt sources
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

# Update package manager repositories to include Trivy
sudo apt-get update

# Install Trivy
sudo apt-get install -y trivy

# Optional: Confirm installation
trivy --version
echo "Trivy installation completed successfully!"

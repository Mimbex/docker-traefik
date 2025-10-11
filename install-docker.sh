#!/bin/bash

echo "🐳 Installing Docker and Docker Compose..."
echo "=========================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "❌ Please do not run this script as root or with sudo"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ Cannot detect OS"
    exit 1
fi

echo "📋 Detected OS: $OS"

# Update package index
echo ""
echo "📦 Updating package index..."
sudo apt-get update

# Install prerequisites
echo ""
echo "📦 Installing prerequisites..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
echo ""
echo "🔑 Adding Docker's official GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo ""
echo "📚 Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
echo ""
echo "📦 Updating package index with Docker repository..."
sudo apt-get update

# Install Docker Engine
echo ""
echo "🐳 Installing Docker Engine..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create docker group if it doesn't exist
echo ""
echo "👥 Creating docker group..."
sudo groupadd docker 2>/dev/null || true

# Add current user to docker group
echo ""
echo "👤 Adding current user ($USER) to docker group..."
sudo usermod -aG docker $USER

# Enable Docker service
echo ""
echo "🚀 Enabling Docker service..."
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Start Docker service
echo ""
echo "▶️  Starting Docker service..."
sudo systemctl start docker.service

# Verify installation
echo ""
echo "✅ Verifying Docker installation..."
sudo docker --version
sudo docker compose version

echo ""
echo "=========================================="
echo "✅ Docker installation completed!"
echo ""
echo "⚠️  IMPORTANT: You need to log out and log back in"
echo "   for the group changes to take effect."
echo ""
echo "   After logging back in, you can run Docker"
echo "   commands without sudo."
echo ""
echo "   To apply changes without logging out, run:"
echo "   newgrp docker"
echo "=========================================="
echo ""
echo "by Dustin Mimbela"

#!/bin/bash

echo "🐳 Installing Docker and Docker Compose..."
echo "=========================================="

# Get the actual user if running with sudo
if [ -n "$SUDO_USER" ]; then
    ACTUAL_USER=$SUDO_USER
else
    ACTUAL_USER=$USER
fi

echo "👤 Installing for user: $ACTUAL_USER"

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
apt-get update

# Install prerequisites
echo ""
echo "📦 Installing prerequisites..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
echo ""
echo "🔑 Adding Docker's official GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$OS/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo ""
echo "📚 Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
echo ""
echo "📦 Updating package index with Docker repository..."
apt-get update

# Unhold packages if they are held
echo ""
echo "🔓 Unholding Docker packages..."
apt-mark unhold docker-ce docker-ce-cli containerd.io 2>/dev/null || true

# Install Docker Engine 28.x (compatible with Traefik v2.10)
echo ""
echo "🐳 Installing Docker Engine 28.x (compatible with Traefik v2.10)..."
apt-get install -y --allow-change-held-packages docker-ce=5:28.* docker-ce-cli=5:28.* containerd.io docker-buildx-plugin docker-compose-plugin

# Hold Docker version to prevent auto-updates
echo ""
echo "🔒 Locking Docker version..."
apt-mark hold docker-ce docker-ce-cli

# Configure Docker daemon for compatibility
echo ""
echo "⚙️  Configuring Docker daemon..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# Create docker group if it doesn't exist
echo ""
echo "👥 Creating docker group..."
groupadd docker 2>/dev/null || true

# Add actual user to docker group
echo ""
echo "👤 Adding user ($ACTUAL_USER) to docker group..."
usermod -aG docker $ACTUAL_USER

# Enable Docker service
echo ""
echo "🚀 Enabling Docker service..."
systemctl enable docker.service
systemctl enable containerd.service

# Start Docker service
echo ""
echo "▶️  Starting Docker service..."
systemctl start docker.service

# Verify installation
echo ""
echo "✅ Verifying Docker installation..."
docker --version
docker compose version

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

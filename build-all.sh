#!/bin/bash

echo "🔨 Building all services..."

# Create Docker networks if they don't exist
echo "🌐 Checking Docker networks..."
if ! docker network inspect traefik-network &> /dev/null; then
    echo "  Creating traefik-network..."
    docker network create traefik-network
else
    echo "  ✓ traefik-network already exists"
fi

if ! docker network inspect postgres-network &> /dev/null; then
    echo "  Creating postgres-network..."
    docker network create postgres-network
else
    echo "  ✓ postgres-network already exists"
fi

# Build Traefik
echo "📦 Building Traefik..."
cd traefik && docker compose build && cd ..

# Build PostgreSQL
echo "📦 Building PostgreSQL..."
cd postgresql && docker compose build && cd ..

# Build Odoo
echo "📦 Building Odoo..."
cd odoo && docker compose build && cd ..

echo "✅ All services built successfully!"

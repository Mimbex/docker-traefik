#!/bin/bash

echo "🚀 Starting all services..."

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

# Start Traefik
echo "▶️  Starting Traefik..."
cd traefik && docker compose up -d && cd ..

# Start PostgreSQL
echo "▶️  Starting PostgreSQL..."
cd postgresql && docker compose up -d && cd ..

# Start Odoo
echo "▶️  Starting Odoo..."
cd odoo && docker compose up -d && cd ..

echo "✅ All services started successfully!"
docker ps

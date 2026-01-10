#!/bin/bash

echo "🚀 Starting all services..."

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

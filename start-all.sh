#!/bin/bash

echo "🚀 Starting all services..."

# Start Traefik
echo "▶️  Starting Traefik..."
cd traefik && docker compose up -d && cd ..

# Start PostgreSQL
echo "▶️  Starting PostgreSQL..."
cd postgresql && docker compose up -d && cd ..

# Start Odoo19
echo "▶️  Starting Odoo19..."
cd odoo19 && docker compose up -d && cd ..

echo "✅ All services started successfully!"
docker ps

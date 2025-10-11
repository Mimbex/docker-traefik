#!/bin/bash

echo "🛑 Stopping all services..."

# Stop Odoo19
echo "⏹️  Stopping Odoo19..."
cd odoo19 && docker compose down && cd ..

# Stop PostgreSQL
echo "⏹️  Stopping PostgreSQL..."
cd postgresql && docker compose down && cd ..

# Stop Traefik
echo "⏹️  Stopping Traefik..."
cd traefik && docker compose down && cd ..

echo "✅ All services stopped successfully!"

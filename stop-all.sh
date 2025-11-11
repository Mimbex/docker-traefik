#!/bin/bash

echo "🛑 Stopping all services..."

# Stop Odoo
echo "⏹️  Stopping Odoo..."
cd odoo && docker compose down && cd ..

# Stop PostgreSQL
echo "⏹️  Stopping PostgreSQL..."
cd postgresql && docker compose down && cd ..

# Stop Traefik
echo "⏹️  Stopping Traefik..."
cd traefik && docker compose down && cd ..

echo "✅ All services stopped successfully!"

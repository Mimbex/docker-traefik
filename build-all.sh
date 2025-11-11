#!/bin/bash

echo "🔨 Building all services..."

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

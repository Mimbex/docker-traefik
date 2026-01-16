#!/bin/bash

# 🚀 One-Command Deployment Script
# Prerequisites: Edit .env files in traefik/, postgresql/, and odoo/ directories
# Then run: ./deploy.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}    ${GREEN}Odoo + Traefik + PostgreSQL Deployment${NC}         ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 0: Check and install Docker
echo -e "${BLUE}🐳 Step 0: Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker not found. Installing...${NC}"
    if [ -f "install-docker.sh" ]; then
        chmod +x install-docker.sh
        ./install-docker.sh
        echo -e "${GREEN}✓${NC} Docker installed successfully"
        
        # Check if running as root
        if [ "$EUID" -ne 0 ]; then
            echo -e "${YELLOW}⚠️  Please log out and log back in, or run: newgrp docker${NC}"
            echo -e "${YELLOW}⚠️  Then run this script again.${NC}"
            exit 0
        else
            echo -e "${GREEN}✓${NC} Running as root, continuing deployment..."
        fi
    else
        echo -e "${RED}✗${NC} install-docker.sh not found!"
        echo -e "${YELLOW}Please install Docker manually:${NC}"
        echo "  Ubuntu/Debian: sudo apt install docker.io docker-compose-plugin"
        echo "  CentOS/RHEL: sudo yum install docker docker-compose-plugin"
        echo "  Or visit: https://docs.docker.com/engine/install/"
        exit 1
    fi
else
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓${NC} Docker is installed: $DOCKER_VERSION"
fi
echo ""

# Step 1: Check .env files
echo -e "${BLUE}📋 Step 1: Checking .env files...${NC}"
missing_env=0

if [ ! -f "traefik/.env" ]; then
    echo -e "${RED}✗${NC} traefik/.env not found!"
    missing_env=1
fi

if [ ! -f "postgresql/.env" ]; then
    echo -e "${RED}✗${NC} postgresql/.env not found!"
    missing_env=1
fi

if [ ! -f "odoo/.env" ]; then
    echo -e "${RED}✗${NC} odoo/.env not found!"
    missing_env=1
fi

if [ $missing_env -eq 1 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Please create and configure the following .env files:${NC}"
    echo ""
    echo "1. traefik/.env - Example:"
    echo "   LETS_ENCRYPT_CONTACT_EMAIL=admin@yourdomain.com"
    echo "   DOMAIN_NAME=\`traefik.yourdomain.com\`"
    echo ""
    echo "2. postgresql/.env - Example:"
    echo "   POSTGRES_DB=postgres"
    echo "   POSTGRES_PASSWORD=odoo"
    echo "   POSTGRES_USER=odoo"
    echo ""
    echo "3. odoo/.env - Example:"
    echo "   DEPLOYMENT_MODE=image"
    echo "   ODOO_VERSION=19.0"
    echo "   HOST=postgresql"
    echo "   USER=odoo"
    echo "   PASSWORD=odoo"
    echo "   DOMAIN=\`odoo.yourdomain.com\`"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓${NC} All .env files found"
echo ""

# Step 2: Create Docker networks
echo -e "${BLUE}📡 Step 2: Creating Docker networks...${NC}"
docker network create traefik-network 2>/dev/null && echo -e "${GREEN}✓${NC} traefik-network created" || echo -e "${YELLOW}✓${NC} traefik-network already exists"
docker network create postgres-network 2>/dev/null && echo -e "${GREEN}✓${NC} postgres-network created" || echo -e "${YELLOW}✓${NC} postgres-network already exists"
echo ""

# Step 3: Configure Let's Encrypt
echo -e "${BLUE}🔒 Step 3: Configuring Let's Encrypt...${NC}"
mkdir -p traefik/letsencrypt
touch traefik/letsencrypt/acme.json
chmod 600 traefik/letsencrypt/acme.json
echo -e "${GREEN}✓${NC} Let's Encrypt configured"
echo ""

# Step 4: Build all services
echo -e "${BLUE}🔨 Step 4: Building all services...${NC}"
chmod +x build-all.sh
./build-all.sh
echo ""

# Step 5: Start all services
echo -e "${BLUE}🚀 Step 5: Starting all services...${NC}"
chmod +x start-all.sh
./start-all.sh
echo ""

# Step 6: Display summary
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}              ${GREEN}✅ Deployment Complete!${NC}                ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Read configuration from .env files
ODOO_DOMAIN=$(grep "^DOMAIN=" odoo/.env | cut -d'=' -f2 | tr -d '`')
TRAEFIK_DOMAIN=$(grep "^DOMAIN_NAME=" traefik/.env | cut -d'=' -f2 | tr -d '`')

echo -e "${BLUE}📊 Deployment Summary:${NC}"
echo ""
echo -e "${GREEN}🌐 Access URLs:${NC}"
echo "  • Odoo: https://$ODOO_DOMAIN"
echo "  • Traefik Dashboard: https://$TRAEFIK_DOMAIN:8080"
echo ""

# Check longpolling configuration
WORKERS=$(grep "^workers" odoo/odoo.conf | awk '{print $3}')
GEVENT_PORT=$(grep "^gevent_port" odoo/odoo.conf | awk '{print $3}')

echo -e "${GREEN}🔍 Longpolling Status:${NC}"
if [ "$WORKERS" -ge 2 ] 2>/dev/null; then
    echo -e "  • Workers: ${GREEN}$WORKERS${NC} (longpolling ${GREEN}ENABLED ✓${NC})"
    echo -e "  • Gevent Port: ${GREEN}$GEVENT_PORT${NC}"
    echo -e "  • WebSocket: ${GREEN}wss://$ODOO_DOMAIN/websocket${NC}"
else
    echo -e "  • Workers: ${RED}$WORKERS${NC} (longpolling ${RED}DISABLED ✗${NC})"
    echo -e "  ${YELLOW}⚠️  Set workers >= 2 in odoo/odoo.conf to enable longpolling${NC}"
fi
echo ""

echo -e "${BLUE}📋 Next Steps:${NC}"
echo "  1. Wait 2-3 minutes for SSL certificates to be issued"
echo "  2. Configure DNS to point domains to this server's IP"
echo "  3. Access your Odoo instance at: https://$ODOO_DOMAIN"
echo "  4. Default master password: odooPassword (change in odoo/odoo.conf)"
echo ""

echo -e "${BLUE}🔧 Useful Commands:${NC}"
echo "  • View logs: cd odoo && docker compose logs -f"
echo "  • Restart all: ./stop-all.sh && ./start-all.sh"
echo "  • Stop all: ./stop-all.sh"
echo "  • Check status: docker ps"
echo ""

echo -e "${GREEN}🎉 Happy deploying!${NC}"

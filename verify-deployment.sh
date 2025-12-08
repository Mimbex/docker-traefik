#!/bin/bash

# ============================================================
# Deployment Verification Script
# ============================================================
# This script verifies that your Docker Traefik + Odoo
# deployment is configured correctly
# ============================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to print colored messages
print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_check() {
    echo -e "${BLUE}[CHECK]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}  ✓${NC} $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}  ✗${NC} $1"
    ((FAILED++))
}

print_warn() {
    echo -e "${YELLOW}  ⚠${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}  ℹ${NC} $1"
}

# Start verification
clear
print_header "Docker Traefik + Odoo Deployment Verification"

# ============================================================
# Check 1: Docker Installation
# ============================================================
print_check "Checking Docker installation..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
    print_pass "Docker is installed (version: $DOCKER_VERSION)"
else
    print_fail "Docker is not installed"
    echo ""
    print_info "Install Docker with: sudo ./install-docker.sh"
    exit 1
fi

# ============================================================
# Check 2: Docker Compose
# ============================================================
print_check "Checking Docker Compose..."
if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version | cut -d ' ' -f4)
    print_pass "Docker Compose is available (version: $COMPOSE_VERSION)"
else
    print_fail "Docker Compose is not available"
    exit 1
fi

# ============================================================
# Check 3: Docker Networks
# ============================================================
print_check "Checking Docker networks..."
if docker network inspect traefik-network &> /dev/null; then
    print_pass "traefik-network exists"
else
    print_fail "traefik-network does not exist"
    print_info "Create with: docker network create traefik-network"
fi

if docker network inspect postgres-network &> /dev/null; then
    print_pass "postgres-network exists"
else
    print_fail "postgres-network does not exist"
    print_info "Create with: docker network create postgres-network"
fi

# ============================================================
# Check 4: Traefik Configuration
# ============================================================
print_check "Checking Traefik configuration..."
if [ -f "traefik/.env" ]; then
    print_pass "traefik/.env exists"
    
    # Check for required variables
    if grep -q "LETS_ENCRYPT_CONTACT_EMAIL" traefik/.env; then
        EMAIL=$(grep "LETS_ENCRYPT_CONTACT_EMAIL" traefik/.env | cut -d '=' -f2)
        if [ "$EMAIL" != "your-email@example.com" ]; then
            print_pass "Let's Encrypt email configured: $EMAIL"
        else
            print_warn "Let's Encrypt email not changed from default"
        fi
    else
        print_fail "LETS_ENCRYPT_CONTACT_EMAIL not found in traefik/.env"
    fi
    
    if grep -q "DOMAIN_NAME" traefik/.env; then
        DOMAIN=$(grep "DOMAIN_NAME" traefik/.env | cut -d '=' -f2)
        print_pass "Traefik domain configured: $DOMAIN"
    else
        print_fail "DOMAIN_NAME not found in traefik/.env"
    fi
else
    print_fail "traefik/.env not found"
fi

# Check acme.json
if [ -f "traefik/letsencrypt/acme.json" ]; then
    print_pass "traefik/letsencrypt/acme.json exists"
    
    # Check permissions
    PERMS=$(stat -f "%OLp" traefik/letsencrypt/acme.json 2>/dev/null || stat -c "%a" traefik/letsencrypt/acme.json 2>/dev/null)
    if [ "$PERMS" = "600" ]; then
        print_pass "acme.json has correct permissions (600)"
    else
        print_fail "acme.json has incorrect permissions ($PERMS), should be 600"
        print_info "Fix with: chmod 600 traefik/letsencrypt/acme.json"
    fi
else
    print_fail "traefik/letsencrypt/acme.json not found"
    print_info "Create with: touch traefik/letsencrypt/acme.json && chmod 600 traefik/letsencrypt/acme.json"
fi

# ============================================================
# Check 5: PostgreSQL Configuration
# ============================================================
print_check "Checking PostgreSQL configuration..."
if [ -f "postgresql/.env" ]; then
    print_pass "postgresql/.env exists"
    
    if grep -q "POSTGRES_USER" postgresql/.env; then
        print_pass "POSTGRES_USER configured"
    else
        print_fail "POSTGRES_USER not found in postgresql/.env"
    fi
    
    if grep -q "POSTGRES_PASSWORD" postgresql/.env; then
        print_pass "POSTGRES_PASSWORD configured"
    else
        print_fail "POSTGRES_PASSWORD not found in postgresql/.env"
    fi
else
    print_fail "postgresql/.env not found"
fi

# ============================================================
# Check 6: Odoo Configuration
# ============================================================
print_check "Checking Odoo configuration..."
if [ -f "odoo/.env" ]; then
    print_pass "odoo/.env exists"
    
    # Check deployment mode
    if grep -q "DEPLOYMENT_MODE" odoo/.env; then
        MODE=$(grep "DEPLOYMENT_MODE" odoo/.env | cut -d '=' -f2)
        print_pass "Deployment mode: $MODE"
        
        if [ "$MODE" = "image" ]; then
            if grep -q "ODOO_VERSION" odoo/.env; then
                VERSION=$(grep "ODOO_VERSION" odoo/.env | cut -d '=' -f2)
                print_pass "Odoo version: $VERSION"
            else
                print_fail "ODOO_VERSION not found (required for image mode)"
            fi
        elif [ "$MODE" = "source" ]; then
            if grep -q "ODOO_BRANCH" odoo/.env; then
                BRANCH=$(grep "ODOO_BRANCH" odoo/.env | cut -d '=' -f2)
                print_pass "Odoo branch: $BRANCH"
            else
                print_fail "ODOO_BRANCH not found (required for source mode)"
            fi
        else
            print_warn "Unknown deployment mode: $MODE"
        fi
    else
        print_fail "DEPLOYMENT_MODE not found in odoo/.env"
    fi
    
    if grep -q "DOMAIN" odoo/.env; then
        ODOO_DOMAIN=$(grep "^DOMAIN" odoo/.env | cut -d '=' -f2)
        print_pass "Odoo domain configured: $ODOO_DOMAIN"
    else
        print_fail "DOMAIN not found in odoo/.env"
    fi
else
    print_fail "odoo/.env not found"
    print_info "Copy from template: cp odoo/.env.example odoo/.env"
fi

# Check Dockerfiles
if [ -f "odoo/Dockerfile.image" ]; then
    print_pass "odoo/Dockerfile.image exists"
else
    print_fail "odoo/Dockerfile.image not found"
fi

if [ -f "odoo/Dockerfile.source" ]; then
    print_pass "odoo/Dockerfile.source exists"
else
    print_fail "odoo/Dockerfile.source not found"
fi

# Check deploy script
if [ -f "odoo/deploy.sh" ]; then
    print_pass "odoo/deploy.sh exists"
    if [ -x "odoo/deploy.sh" ]; then
        print_pass "odoo/deploy.sh is executable"
    else
        print_warn "odoo/deploy.sh is not executable"
        print_info "Fix with: chmod +x odoo/deploy.sh"
    fi
else
    print_fail "odoo/deploy.sh not found"
fi

# ============================================================
# Check 7: Running Containers
# ============================================================
print_check "Checking running containers..."
if docker ps --format '{{.Names}}' | grep -q "traefik"; then
    print_pass "Traefik container is running"
else
    print_warn "Traefik container is not running"
    print_info "Start with: cd traefik && docker compose up -d"
fi

if docker ps --format '{{.Names}}' | grep -q "postgresql"; then
    print_pass "PostgreSQL container is running"
else
    print_warn "PostgreSQL container is not running"
    print_info "Start with: cd postgresql && docker compose up -d"
fi

if docker ps --format '{{.Names}}' | grep -q "odoo"; then
    print_pass "Odoo container is running"
else
    print_warn "Odoo container is not running"
    print_info "Start with: cd odoo && docker compose up -d"
fi

# ============================================================
# Check 8: Management Scripts
# ============================================================
print_check "Checking management scripts..."
for script in build-all.sh start-all.sh stop-all.sh; do
    if [ -f "$script" ]; then
        print_pass "$script exists"
        if [ -x "$script" ]; then
            print_pass "$script is executable"
        else
            print_warn "$script is not executable"
            print_info "Fix with: chmod +x $script"
        fi
    else
        print_fail "$script not found"
    fi
done

# ============================================================
# Check 9: Documentation
# ============================================================
print_check "Checking documentation..."
docs=("README.md" "QUICK_START.md" "DEPLOYMENT_DECISION.md" "ARCHITECTURE.md" "SUMMARY.md")
for doc in "${docs[@]}"; do
    if [ -f "$doc" ]; then
        print_pass "$doc exists"
    else
        print_warn "$doc not found"
    fi
done

# ============================================================
# Summary
# ============================================================
echo ""
print_header "Verification Summary"

echo -e "${GREEN}Passed:${NC}   $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC}   $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ All critical checks passed!                        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}Note: There are $WARNINGS warning(s) that should be addressed.${NC}"
        echo ""
    fi
    
    echo "🚀 Your deployment is ready!"
    echo ""
    echo "Next steps:"
    echo "  1. Review any warnings above"
    echo "  2. Start services: ./start-all.sh"
    echo "  3. Check logs: docker compose logs -f"
    echo ""
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ✗ Some checks failed!                                ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Please fix the failed checks before deploying."
    echo ""
    echo "Quick fixes:"
    echo "  • Create networks: docker network create traefik-network"
    echo "  • Configure .env files: See .env.example files"
    echo "  • Fix permissions: chmod 600 traefik/letsencrypt/acme.json"
    echo ""
    exit 1
fi

# ============================================================
# Additional Information
# ============================================================
if [ $FAILED -eq 0 ]; then
    echo "📚 Documentation:"
    echo "  • Quick Start: cat QUICK_START.md"
    echo "  • Deployment Guide: cat odoo/DEPLOYMENT_GUIDE.md"
    echo "  • Architecture: cat ARCHITECTURE.md"
    echo ""
    echo "🛠️ Useful Commands:"
    echo "  • Build all: ./build-all.sh"
    echo "  • Start all: ./start-all.sh"
    echo "  • Stop all: ./stop-all.sh"
    echo "  • View logs: docker compose logs -f"
    echo ""
fi

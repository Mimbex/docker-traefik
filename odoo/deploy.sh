#!/bin/bash

# ============================================================
# Odoo Deployment Helper Script
# ============================================================
# This script helps you deploy Odoo with different configurations
# ============================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${NC}$1"
}

print_error() {
    echo -e "${RED}✗ ${NC}$1"
}

# Function to display menu
show_menu() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${GREEN}Odoo Deployment Configuration${NC}              ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Select deployment mode:"
    echo ""
    echo "  1) Official Docker Image (Recommended for Production)"
    echo "     - Fast deployment"
    echo "     - Stable releases (19.0, 18.0, 17.0, etc.)"
    echo ""
    echo "  2) Git Clone from Source (For Development/Specific Branches)"
    echo "     - Clone from repository"
    echo "     - Specific branches (e.g., saas-18.4, master)"
    echo "     - Custom repositories"
    echo ""
    echo "  3) View Current Configuration"
    echo ""
    echo "  4) Exit"
    echo ""
}

# Function to configure image deployment
configure_image_deployment() {
    clear
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Official Docker Image Deployment${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    
    print_info "Available versions: 19.0, 18.0, 17.0, 16.0, 15.0, 14.0, etc."
    echo ""
    read -p "Enter Odoo version [19.0]: " odoo_version
    odoo_version=${odoo_version:-19.0}
    
    # Update .env file
    sed -i.bak "s/^DEPLOYMENT_MODE=.*/DEPLOYMENT_MODE=image/" .env
    sed -i.bak "s/^ODOO_VERSION=.*/ODOO_VERSION=${odoo_version}/" .env
    
    print_success "Configuration updated!"
    echo ""
    print_info "Deployment Mode: Official Docker Image"
    print_info "Odoo Version: ${odoo_version}"
    echo ""
}

# Function to configure source deployment
configure_source_deployment() {
    clear
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Git Clone Source Deployment${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    
    print_info "Default repository: https://github.com/odoo/odoo.git"
    read -p "Enter Git repository URL [press Enter for default]: " repo_url
    repo_url=${repo_url:-https://github.com/odoo/odoo.git}
    
    echo ""
    print_info "Popular branches:"
    echo "  - master (latest development)"
    echo "  - saas-18.4 (SaaS version 18.4)"
    echo "  - saas-17.4 (SaaS version 17.4)"
    echo "  - 19.0, 18.0, 17.0 (stable branches)"
    echo ""
    read -p "Enter branch name [saas-18.4]: " branch_name
    branch_name=${branch_name:-saas-18.4}
    
    # Update .env file
    sed -i.bak "s/^DEPLOYMENT_MODE=.*/DEPLOYMENT_MODE=source/" .env
    sed -i.bak "s|^ODOO_REPO=.*|ODOO_REPO=${repo_url}|" .env
    sed -i.bak "s/^ODOO_BRANCH=.*/ODOO_BRANCH=${branch_name}/" .env
    
    print_success "Configuration updated!"
    echo ""
    print_info "Deployment Mode: Git Clone Source"
    print_info "Repository: ${repo_url}"
    print_info "Branch: ${branch_name}"
    echo ""
}

# Function to view current configuration
view_configuration() {
    clear
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Current Configuration${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f .env ]; then
        source .env
        echo -e "${GREEN}Deployment Mode:${NC} ${DEPLOYMENT_MODE}"
        echo ""
        
        if [ "$DEPLOYMENT_MODE" = "image" ]; then
            echo -e "${GREEN}Odoo Version:${NC} ${ODOO_VERSION}"
            echo -e "${GREEN}Image:${NC} odoo:${ODOO_VERSION}"
        else
            echo -e "${GREEN}Repository:${NC} ${ODOO_REPO}"
            echo -e "${GREEN}Branch:${NC} ${ODOO_BRANCH}"
        fi
        
        echo ""
        echo -e "${GREEN}Database Configuration:${NC}"
        echo -e "  Host: ${HOST}"
        echo -e "  User: ${USER}"
        echo ""
        echo -e "${GREEN}Domain:${NC} ${DOMAIN}"
    else
        print_error ".env file not found!"
    fi
    
    echo ""
}

# Function to build and start
build_and_start() {
    # Check and create Docker networks if they don't exist
    print_info "Checking Docker networks..."
    if ! docker network inspect traefik-network &> /dev/null; then
        print_info "Creating traefik-network..."
        docker network create traefik-network
    fi
    
    if ! docker network inspect postgres-network &> /dev/null; then
        print_info "Creating postgres-network..."
        docker network create postgres-network
    fi
    
    print_info "Building Docker image..."
    docker compose build
    
    print_success "Build completed!"
    echo ""
    
    read -p "Do you want to start the container now? (y/n) [y]: " start_now
    start_now=${start_now:-y}
    
    if [ "$start_now" = "y" ] || [ "$start_now" = "Y" ]; then
        print_info "Starting Odoo container..."
        docker compose up -d
        print_success "Odoo is starting!"
        echo ""
        print_info "Check logs with: docker compose logs -f"
    fi
}

# Main script
main() {
    while true; do
        show_menu
        read -p "Select an option [1-4]: " choice
        
        case $choice in
            1)
                configure_image_deployment
                read -p "Build and start now? (y/n) [y]: " build_now
                build_now=${build_now:-y}
                if [ "$build_now" = "y" ] || [ "$build_now" = "Y" ]; then
                    build_and_start
                fi
                read -p "Press Enter to continue..."
                ;;
            2)
                configure_source_deployment
                read -p "Build and start now? (y/n) [y]: " build_now
                build_now=${build_now:-y}
                if [ "$build_now" = "y" ] || [ "$build_now" = "Y" ]; then
                    build_and_start
                fi
                read -p "Press Enter to continue..."
                ;;
            3)
                view_configuration
                read -p "Press Enter to continue..."
                ;;
            4)
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please try again."
                sleep 2
                ;;
        esac
    done
}

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found!"
    print_error "Please run this script from the odoo directory."
    exit 1
fi

# Run main function
main

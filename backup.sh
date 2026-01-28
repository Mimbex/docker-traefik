#!/bin/bash

# 🛡️ Odoo Backup Script
# Backups Database (PostgreSQL) and Filestore (Odoo Data Volume)

set -e

# Configuration
BACKUP_DIR="./backups"
RETENTION_DAYS=7
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_PATH="${BACKUP_DIR}/${TIMESTAMP}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Load PostgreSQL variables
if [ -f postgresql/.env ]; then
    export $(grep -v '^#' postgresql/.env | xargs)
else
    echo -e "${RED}Error: postgresql/.env not found!${NC}"
    exit 1
fi

echo -e "${BLUE}Starting Backup: ${TIMESTAMP}${NC}"
mkdir -p "$BACKUP_PATH"

# 1. Database Backup
echo -e "${YELLOW}📦 Backing up Database...${NC}"
# Use pg_dumpall to backup all databases including globals (users, groups)
docker exec -t postgresql-postgresql-1 pg_dumpall -c -U "$POSTGRES_USER" > "${BACKUP_PATH}/dump.sql"
echo -e "${GREEN}✓ Database backup completed${NC}"

# 2. Filestore Backup
echo -e "${YELLOW}🗂️  Backing up Filestore...${NC}"
# Using a temporary container to access the volume
docker run --rm --volumes-from odoo-odoo-1 -v "${PWD}/${BACKUP_PATH}:/backup" alpine tar czf /backup/filestore.tar.gz /var/lib/odoo
echo -e "${GREEN}✓ Filestore backup completed${NC}"

# 3. Compress final archive
echo -e "${YELLOW}🔒 Compressing backup...${NC}"
tar czf "${BACKUP_PATH}.tar.gz" -C "${BACKUP_DIR}" "${TIMESTAMP}"
rm -rf "${BACKUP_PATH}" # Remove uncompressed folder
echo -e "${GREEN}✓ Backup compressed: ${BACKUP_PATH}.tar.gz${NC}"

# 4. Cleanup old backups
echo -e "${YELLOW}🧹 Cleaning up old backups (> ${RETENTION_DAYS} days)...${NC}"
find "$BACKUP_DIR" -name "*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete
echo -e "${GREEN}✓ Cleanup completed${NC}"

echo -e "${BLUE}🎉 Backup finished successfully!${NC}"
echo -e "File: ${BACKUP_PATH}.tar.gz"

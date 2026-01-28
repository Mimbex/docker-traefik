#!/bin/bash

# ♻️ Odoo Restore Script
# Restores Database and Filestore from a selected backup

set -e

BACKUP_DIR="./backups"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if backups exist
if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR)" ]; then
    echo -e "${RED}No backups found in $BACKUP_DIR${NC}"
    exit 1
fi

# Select Backup
echo -e "${BLUE}Available Backups:${NC}"
PS3="Select backup to restore (Enter number): "
select filename in $(ls "$BACKUP_DIR"/*.tar.gz); do
    if [ -n "$filename" ]; then
        BACKUP_FILE=$filename
        break
    else
        echo -e "${RED}Invalid selection${NC}"
    fi
done

echo -e "${YELLOW}⚠️  WARNING: This will OVERWRITE your current database and filestore!${NC}"
echo -e "${YELLOW}⚠️  Make sure you understand what you are doing.${NC}"
read -p "Are you sure you want to proceed? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

# Load PostgreSQL variables
if [ -f postgresql/.env ]; then
    export $(grep -v '^#' postgresql/.env | xargs)
else
    echo -e "${RED}Error: postgresql/.env not found!${NC}"
    exit 1
fi

TEMP_DIR="./restore_temp"
mkdir -p "$TEMP_DIR"

echo -e "${BLUE}🚀 Starting Restore Process...${NC}"

# 1. Extract Backup
echo -e "${YELLOW}📦 Extracting backup...${NC}"
tar xzf "$BACKUP_FILE" -C "$TEMP_DIR"
# The tar contains a folder with the timestamp name, we need to find it
EXTRACTED_FOLDER=$(ls "$TEMP_DIR" | head -1)
RESTORE_PATH="${TEMP_DIR}/${EXTRACTED_FOLDER}"
echo -e "${GREEN}✓ Extracted to $RESTORE_PATH${NC}"

# 2. Stop Odoo (to release DB connections and file locks)
echo -e "${YELLOW}🛑 Stopping Odoo service...${NC}"
docker stop odoo-odoo-1
echo -e "${GREEN}✓ Odoo stopped${NC}"

# 3. Restore Database
echo -e "${YELLOW}♻️  Restoring Database...${NC}"
# Wait a bit for connections to close
sleep 3
# Restore using psql
cat "${RESTORE_PATH}/dump.sql" | docker exec -i postgresql-postgresql-1 psql -U "$POSTGRES_USER" postgres
echo -e "${GREEN}✓ Database restored${NC}"

# 4. Restore Filestore
echo -e "${YELLOW}🗂️  Restoring Filestore...${NC}"
# We use a temporary container to clean and restore the volume
# First, clean existing volume content to avoid mixing files
docker run --rm --volumes-from odoo-odoo-1 alpine sh -c "rm -rf /var/lib/odoo/*"
# Then extract the tar.gz
# Note: The tar was created with absolute path /var/lib/odoo, so tar -C / will put it in the right place relative to the volume mount?
# Wait, previous script did: tar czf /backup/filestore.tar.gz /var/lib/odoo
# This creates archive containing var/lib/odoo structure usually.
# Let's check restoration method.
# We mount the extracted backup folder to /backup
docker run --rm --volumes-from odoo-odoo-1 -v "${PWD}/${RESTORE_PATH}:/backup" alpine tar xzf /backup/filestore.tar.gz -C /
echo -e "${GREEN}✓ Filestore restored${NC}"

# 5. Cleanup
echo -e "${YELLOW}🧹 Cleaning up temporary files...${NC}"
rm -rf "$TEMP_DIR"
echo -e "${GREEN}✓ Cleanup completed${NC}"

# 6. Restart Odoo
echo -e "${YELLOW}▶️  Restarting Odoo...${NC}"
docker start odoo-odoo-1
echo -e "${BLUE}🎉 Restore process finished successfully!${NC}"

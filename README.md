# Docker Traefik + Odoo 19 + PostgreSQL

Complete development stack with Traefik as reverse proxy, automatic SSL certificates with Let's Encrypt, PostgreSQL 17, and Odoo 19.

## 📋 Project Structure

```
docker-traefik/
├── traefik/           # Reverse proxy with automatic SSL
├── postgresql/        # PostgreSQL 17 database
├── odoo19/           # Odoo 19 with custom configuration
├── build-all.sh      # Script to build all services
├── start-all.sh      # Script to start all services
└── stop-all.sh       # Script to stop all services
```

## 🚀 Quick Start

### 0. Install Docker (Optional)

If you don't have Docker installed, run the installation script with sudo:

```bash
sudo ./install-docker.sh
```

After installation, **log out and log back in** for the changes to take effect, or run:

```bash
newgrp docker
```

Then you can use Docker without sudo.

### 1. Configure Docker Networks

```bash
docker network create traefik-network
docker network create postgres-network
```

### 2. Configure Let's Encrypt Permissions

```bash
mkdir -p traefik/letsencrypt
touch traefik/letsencrypt/acme.json
chmod 600 traefik/letsencrypt/acme.json
```

### 3. Configure Domains

Edit the `.env` files in each folder:

#### `traefik/.env`
```env
LETS_ENCRYPT_CONTACT_EMAIL=your-email@example.com
DOMAIN_NAME=`traefik.yourdomain.com`
```

#### `postgresql/.env`
```env
POSTGRES_DB=postgres
POSTGRES_PASSWORD=odoo
POSTGRES_USER=odoo
```

#### `odoo19/.env`
```env
HOST=postgresql
USER=odoo
PASSWORD=odoo
DOMAIN=demo19.yourdomain.com
```

### 4. Build and Start Services

```bash
# Build all services
./build-all.sh

# Start all services
./start-all.sh

# Check status
docker ps
```

## 🌐 Service Access

- **Traefik Dashboard**: `https://traefik.yourdomain.com:8080`
- **Odoo 19**: `https://demo19.yourdomain.com`
  - Default user: `admin`
  - Master password (odoo.conf): `odooPassword`

## ⚙️ Domain Configuration

The project uses **environment variables** to manage domains, avoiding manual entry in multiple places.

### Change Odoo Domain

Simply edit the `odoo19/.env` file:

```env
DOMAIN=new-domain.yourdomain.com
```

All Traefik routers (HTTP, HTTPS, websockets, etc.) will automatically use this domain.

### Change Traefik Domain

Edit the `traefik/.env` file:

```env
DOMAIN_NAME=`new-traefik.yourdomain.com`
```

## 🛠️ Management Scripts

### `build-all.sh`
Builds all service images:
```bash
./build-all.sh
```

### `start-all.sh`
Starts all services in detached mode:
```bash
./start-all.sh
```

### `stop-all.sh`
Stops all services:
```bash
./stop-all.sh
```

## 📦 Included Services

### Traefik (Reverse Proxy)
- **Version**: v2.10
- **Ports**: 80 (HTTP), 443 (HTTPS), 8080 (Dashboard)
- **Features**:
  - Automatic SSL certificates with Let's Encrypt
  - HTTP → HTTPS redirection
  - GZIP compression
  - Custom size limits (600MB)

### PostgreSQL
- **Version**: 17
- **Network**: `postgres-network` (internal)
- **Persistent volume**: `postgresql-data`

### Odoo 19
- **Internal ports**: 8069 (HTTP), 8072 (WebSocket)
- **Features**:
  - Proxy mode enabled
  - WebSocket for real-time chat
  - Special routes for `/web/database` and `/website/info`
  - Volumes:
    - `odoo19-data`: Odoo data
    - `./extra-addons`: Custom modules
    - `./odoo.conf`: Configuration

## 🔧 Useful Commands

### View service logs
```bash
cd traefik && docker compose logs -f
cd postgresql && docker compose logs -f
cd odoo19 && docker compose logs -f
```

### Restart a specific service
```bash
cd odoo19 && docker compose restart
```

### Rebuild a service
```bash
cd odoo19 && docker compose up -d --build
```

### Check network status
```bash
docker network ls
docker network inspect traefik-network
docker network inspect postgres-network
```

## 🔒 Security

- SSL certificates renew automatically
- PostgreSQL is not publicly exposed (internal network only)
- Configurable passwords in `.env` files
- Traefik Dashboard protected (consider adding basic auth in production)

## 📝 Important Notes

1. **DNS**: Make sure your domains point to the server IP before starting
2. **Firewall**: Open ports 80 and 443 on your server
3. **Let's Encrypt**: Has rate limiting (50 certificates per domain per week)
4. **Production**: Change default passwords in `.env` files

## 🐛 Troubleshooting

### Error: "network not found"
```bash
docker network create traefik-network
docker network create postgres-network
```

### Error: "acme.json permission denied"
```bash
chmod 600 traefik/letsencrypt/acme.json
```

### Odoo doesn't connect to PostgreSQL
Verify both services are on the `postgres-network`:
```bash
docker network inspect postgres-network
```

### SSL certificate not generated
- Verify the domain points correctly to your server
- Check Traefik logs: `cd traefik && docker compose logs -f`
- Make sure ports 80 and 443 are open
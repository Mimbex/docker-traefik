# Docker Traefik + Odoo + PostgreSQL

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Traefik](https://img.shields.io/badge/Traefik-v2.10-24A1C1?logo=traefikproxy&logoColor=white)](https://traefik.io/)
[![Odoo](https://img.shields.io/badge/Odoo-19.0-714B67?logo=odoo&logoColor=white)](https://www.odoo.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)

Production-.ready Odoo deployment with Traefik reverse proxy, automatic SSL certificates, and PostgreSQL 17.

## ✨ Features

- 🚀 **One-Command Deployment** - `./deploy.sh` and you're done
- 🔒 **Automatic HTTPS** - Let's Encrypt SSL certificates with auto-renewal
- 🌐 **WebSocket Support** - Real-time chat and notifications (longpolling enabled)
- 📦 **Dual Deployment Modes** - Official Docker images or Git source
- 🛡️ **Production Ready** - Isolated networks, security best practices
- ⚙️ **Easy Configuration** - Just edit 3 `.env` files

---

## 🚀 Quick Start

### Step 1: Configure `.env` Files

Create and edit three configuration files:

**`traefik/.env`**
```env
LETS_ENCRYPT_CONTACT_EMAIL=admin@yourdomain.com
DOMAIN_NAME=`traefik.yourdomain.com`
```

**`postgresql/.env`**
```env
POSTGRES_DB=postgres
POSTGRES_PASSWORD=strongpassword
POSTGRES_USER=odoo
```

**`odoo/.env`**
```env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0
HOST=postgresql
USER=odoo
PASSWORD=strongpassword
DOMAIN=`odoo.yourdomain.com`
```

### Step 2: Deploy

```bash
chmod +x deploy.sh && ./deploy.sh
```

That's it! 🎉 The script will:
- ✅ Create Docker networks
- ✅ Configure Let's Encrypt
- ✅ Build all services
- ✅ Start everything with longpolling enabled

### Step 3: Access Your Instance

- **Odoo**: `https://odoo.yourdomain.com`
- **Traefik Dashboard**: `https://traefik.yourdomain.com:8080`

**Default Credentials:**
- Master password: `odooPassword` (change in `odoo/odoo.conf`)

---

## 📋 Project Structure

```
docker-traefik/
├── deploy.sh              # One-command deployment script
├── build-all.sh           # Build all services
├── start-all.sh           # Start all services
├── stop-all.sh            # Stop all services
├── traefik/
│   ├── .env               # Traefik configuration
│   └── docker-compose.yml
├── postgresql/
│   ├── .env               # Database configuration
│   └── docker-compose.yml
└── odoo/
    ├── .env               # Odoo configuration
    ├── docker-compose.yml
    ├── odoo.conf          # Odoo settings (workers, longpolling, etc.)
    ├── extra-addons/      # Custom modules
    └── custom-addons/     # Additional modules
```

---

## 🎯 Deployment Modes

### Image Mode (Recommended for Production)

Uses official Odoo Docker images - fast, stable, and production-ready.

```env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0  # or 18.0, 17.0, 16.0, etc.
```

**Pros:**
- ⚡ Fast build (2-5 minutes)
- ✅ Stable and tested
- 💾 Smaller size (~2 GB)
- 🔄 Easy updates (`docker pull`)

### Source Mode (For Development)

Clones Odoo from Git - full source access for customization.

```env
DEPLOYMENT_MODE=source
ODOO_REPO=https://github.com/odoo/odoo.git
ODOO_BRANCH=saas-18.4  # or master, 19.0, etc.
```

**Pros:**
- 🔧 Full source code access
- 🎯 Use specific branches (saas-18.4, master, etc.)
- 🛠️ Easy customization
- 🚀 Development-friendly

**Cons:**
- 🐌 Slower build (10-20 minutes)
- 💾 Larger size (~5-8 GB)

---

## 🏗️ Architecture

```
                    Internet
                       ↓
             ┌──────────────────┐
             │   Traefik v2.10  │ ← Port 80/443
             │   (Reverse Proxy)│
             │   • Auto HTTPS   │
             │   • SSL Certs    │
             └──────────────────┘
                       ↓
            traefik-network (Docker)
                       ↓
             ┌──────────────────┐
             │   Odoo Container │
             │   Port 8069/8072 │ ← Longpolling enabled
             └──────────────────┘
                       ↓
           postgres-network (Docker)
                       ↓
             ┌──────────────────┐
             │  PostgreSQL 17   │
             │   (Internal only)│
             └──────────────────┘
```

**Networks:**
- `traefik-network`: Public-facing (Traefik ↔ Odoo)
- `postgres-network`: Internal only (Odoo ↔ PostgreSQL)

**Security:**
- PostgreSQL is NOT exposed to internet
- Automatic SSL/TLS encryption
- Network isolation

---

## ⚙️ Configuration

### Odoo Configuration (`odoo/odoo.conf`)

Key settings for production:

```ini
# Longpolling (WebSocket support)
workers = 2                  # Must be >= 2 for longpolling
gevent_port = 8072          # WebSocket port

# Database
db_host = postgresql
db_port = 5432
db_user = odoo
db_password = odoo
db_maxconn = 64

# Performance
limit_memory_soft = 4294967296
limit_memory_hard = 5368709120
workers = 2  # Adjust based on CPU cores
```

**Worker Calculation:**
```
workers = (CPU_cores * 2) + 1
```

For production:
- 2 CPU cores → 5 workers
- 4 CPU cores → 9 workers
- 8 CPU cores → 17 workers

---

## 🔧 Management

### View Logs

```bash
cd odoo && docker compose logs -f
cd traefik && docker compose logs -f
cd postgresql && docker compose logs -f
```

### Restart Services

```bash
./stop-all.sh && ./start-all.sh
```

### Update Odoo Version

```bash
# Edit odoo/.env
ODOO_VERSION=18.0

# Rebuild
cd odoo && docker compose up -d --build
```

### Add Custom Modules

```bash
# Place your modules in:
odoo/extra-addons/your_module/

# Restart Odoo
cd odoo && docker compose restart
```

---

## 🐛 Troubleshooting

### Longpolling Not Working

Check if workers >= 2:
```bash
grep "^workers" odoo/odoo.conf
# Should show: workers = 2 or higher
```

If workers = 1, edit `odoo/odoo.conf`:
```ini
workers = 2
```

Then restart:
```bash
cd odoo && docker compose restart
```

Verify in browser DevTools (F12 → Network → WS):
- Should see: `wss://your-domain.com/websocket`
- Status: `101 Switching Protocols`

### SSL Certificate Not Generated

1. Check DNS points to your server IP
2. Ensure ports 80 and 443 are open
3. View Traefik logs:
   ```bash
   cd traefik && docker compose logs -f
   ```

### Cannot Connect to Database

Check both services are on same network:
```bash
docker network inspect postgres-network
```

Verify credentials in `.env` files match.

### Container Won't Start

View detailed logs:
```bash
cd odoo && docker compose logs --tail=50
```

Check if ports are already in use:
```bash
docker ps
netstat -tulpn | grep -E '(8069|8072|5432)'
```

---

## 📊 Deployment Mode Comparison

| Feature | Image Mode | Source Mode |
|---------|-----------|-------------|
| **Build Time** | ⚡ 2-5 minutes | 🐌 10-20 minutes |
| **Disk Space** | 💾 ~2 GB | 💾 ~5-8 GB |
| **Stability** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Customization** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Best For** | Production | Development |
| **Updates** | `docker pull` | `git pull` + rebuild |

---

## 🔒 Security Best Practices

1. **Change Default Passwords**
   - Edit `odoo/odoo.conf` → change `admin_passwd`
   - Edit `postgresql/.env` → change `POSTGRES_PASSWORD`

2. **Firewall Configuration**
   ```bash
   ufw allow 80/tcp
   ufw allow 443/tcp
   ufw enable
   ```

3. **Regular Updates**
   ```bash
   docker compose pull
   docker compose up -d
   ```

4. **Backup Database**
   ```bash
   docker exec postgresql-postgresql-1 pg_dump -U odoo odoo > backup.sql
   ```

---

## 🚀 Advanced Usage

### Multi-Domain Setup

Edit `odoo/.env`:
```env
DOMAIN=`odoo1.com`, `odoo2.com`, `odoo3.com`
```

### Custom Repository (Source Mode)

```env
DEPLOYMENT_MODE=source
ODOO_REPO=https://github.com/yourcompany/odoo-fork.git
ODOO_BRANCH=feature-custom-module
```

### Resource Limits

Add to `docker-compose.yml`:
```yaml
services:
  odoo:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

---

## 📚 Additional Resources

- [Odoo Documentation](https://www.odoo.com/documentation/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Docker Documentation](https://docs.docker.com/)
- [Let's Encrypt](https://letsencrypt.org/)

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- ⭐ Star the repository
- 🐛 Report bugs
- 💡 Suggest features
- 📖 Improve documentation
- 🔀 Submit pull requests

---

## 📄 License

MIT License - see LICENSE file for details.

---

**Made with ❤️ by [Dustin Mimbela](https://github.com/Mimbex)**

**Happy Deploying! 🚀**
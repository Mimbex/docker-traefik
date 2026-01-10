# 🚀 Get Started in 3 Steps

## Step 1: Prerequisites (2 minutes)

### Install Docker
```bash
# If Docker is not installed
sudo ./install-docker.sh
# Then logout and login, or run:
newgrp docker
```

### Create Networks
```bash
docker network create traefik-network
docker network create postgres-network
```

### Configure Let's Encrypt
```bash
mkdir -p traefik/letsencrypt
touch traefik/letsencrypt/acme.json
chmod 600 traefik/letsencrypt/acme.json
```

---

## Step 2: Configure (2 minutes)

### Option A: Interactive (Easiest) ⭐
```bash
cd odoo
./deploy.sh
```
Follow the prompts to configure everything!

### Option B: Manual
Edit configuration files:

**traefik/.env**
```env
LETS_ENCRYPT_CONTACT_EMAIL=your-email@example.com
DOMAIN_NAME=traefik.yourdomain.com
```

**postgresql/.env**
```env
POSTGRES_DB=postgres
POSTGRES_PASSWORD=odoo
POSTGRES_USER=odoo
```

**odoo/.env**
```env
# Choose one deployment mode:

# Option 1: Official Docker Image (Production)
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0

# Option 2: Git Clone Branch (Development)
# DEPLOYMENT_MODE=source
# ODOO_BRANCH=saas-18.4

HOST=postgresql
USER=odoo
PASSWORD=odoo
DOMAIN=demo.yourdomain.com
```

---

## Step 3: Deploy (1 minute)

```bash
# Build all services
./build-all.sh

# Start all services
./start-all.sh

# Check status
docker ps
```

---

## ✅ Verify Deployment

```bash
./verify-deployment.sh
```

This script checks:
- ✓ Docker installation
- ✓ Networks configuration
- ✓ Configuration files
- ✓ Running containers
- ✓ Permissions

---

## 🌐 Access Your Services

- **Odoo**: `https://your-domain.com`
- **Traefik Dashboard**: `https://traefik.yourdomain.com:8080`

---

## 🆘 Troubleshooting

### Quick Fixes

**Networks not found?**
```bash
docker network create traefik-network
docker network create postgres-network
```

**Permission denied (acme.json)?**
```bash
chmod 600 traefik/letsencrypt/acme.json
```

**Container won't start?**
```bash
docker compose logs -f
```

**Need to rebuild?**
```bash
cd odoo
docker compose down
docker compose build --no-cache
docker compose up -d
```

---

## 📚 Next Steps

### Learn More
- [Full Documentation](README.md)
- [Deployment Decision Guide](DEPLOYMENT_DECISION.md)
- [Architecture Overview](ARCHITECTURE.md)

### Customize
- Add custom modules to `odoo/extra-addons/`
- Modify `odoo/odoo.conf` for advanced settings
- Configure multiple domains in `odoo/.env`

### Monitor
```bash
# View logs
docker compose logs -f

# Check container status
docker ps

# Monitor resources
docker stats
```

---

## 🎯 Common Use Cases

### Production ERP
```env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0
DOMAIN=erp.mycompany.com
```

### Development Environment
```env
DEPLOYMENT_MODE=source
ODOO_BRANCH=saas-18.4
DOMAIN=dev.mycompany.com
```

### Testing Latest Features
```env
DEPLOYMENT_MODE=source
ODOO_BRANCH=master
DOMAIN=test.mycompany.com
```

---

## 💡 Pro Tips

1. **Use the verification script** before deploying:
   ```bash
   ./verify-deployment.sh
   ```

2. **Backup before changes**:
   ```bash
   docker exec postgresql-postgresql-1 pg_dump -U odoo odoo > backup.sql
   ```

3. **Monitor logs during deployment**:
   ```bash
   docker compose logs -f --tail=100
   ```

4. **Use .env.example as template**:
   ```bash
   cp odoo/.env.example odoo/.env
   ```

---

## 🎓 Learning Resources

- [Quick Start Guide](QUICK_START.md) - 5-minute setup
- [Deployment Guide](odoo/DEPLOYMENT_GUIDE.md) - Detailed instructions
- [YouTube Tutorial](YOUTUBE_TUTORIAL.md) - Video walkthrough
- [FAQ & Troubleshooting](README.md#troubleshooting)

---

## 🌟 Features

✅ **Dual Deployment Modes** (Image + Source)  
✅ **Automatic HTTPS** (Let's Encrypt)  
✅ **Interactive Setup** (deploy.sh)  
✅ **Multi-Domain Support**  
✅ **Production Ready**  
✅ **Comprehensive Documentation**  

---

**Ready? Start here: `./verify-deployment.sh`**

**Need help? Check [README.md](README.md) or open an issue on GitHub**

**Made with ❤️ for the Odoo community**

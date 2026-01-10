# ⚡ Quick Start Guide

## 🎯 Choose Your Deployment Method

### 🚀 Method 1: Interactive Setup (Easiest)
```bash
cd odoo
./deploy.sh
```
**Perfect for:** First-time users, quick configuration changes

---

### 📦 Method 2: Official Docker Image (Production)
```bash
# 1. Configure
cd odoo
cat > .env << EOF
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0
HOST=postgresql
USER=odoo
PASSWORD=odoo
DOMAIN=demo.yourdomain.com
EOF

# 2. Deploy
docker compose up -d --build
```
**Perfect for:** Production environments, stable releases

---

### 🔧 Method 3: Git Clone Branch (Development)
```bash
# 1. Configure
cd odoo
cat > .env << EOF
DEPLOYMENT_MODE=source
ODOO_REPO=https://github.com/odoo/odoo.git
ODOO_BRANCH=saas-18.4
HOST=postgresql
USER=odoo
PASSWORD=odoo
DOMAIN=dev.yourdomain.com
EOF

# 2. Deploy
docker compose up -d --build
```
**Perfect for:** Development, specific branches (saas-18.4, saas-17.4)

---

## 📋 Prerequisites Checklist

- [ ] Docker installed
- [ ] Docker networks created:
  ```bash
  docker network create traefik-network
  docker network create postgres-network
  ```
- [ ] Let's Encrypt configured:
  ```bash
  mkdir -p traefik/letsencrypt
  touch traefik/letsencrypt/acme.json
  chmod 600 traefik/letsencrypt/acme.json
  ```
- [ ] Domain DNS configured (pointing to your server)

---

## 🎬 Complete Setup (From Scratch)

```bash
# 1. Clone repository
git clone https://github.com/Mimbex/docker-traefik.git
cd docker-traefik

# 2. Create networks
docker network create traefik-network
docker network create postgres-network

# 3. Configure Let's Encrypt
mkdir -p traefik/letsencrypt
touch traefik/letsencrypt/acme.json
chmod 600 traefik/letsencrypt/acme.json

# 4. Configure Traefik
cd traefik
cat > .env << EOF
LETS_ENCRYPT_CONTACT_EMAIL=your-email@example.com
DOMAIN_NAME=traefik.yourdomain.com
EOF
cd ..

# 5. Configure PostgreSQL
cd postgresql
cat > .env << EOF
POSTGRES_DB=postgres
POSTGRES_PASSWORD=odoo
POSTGRES_USER=odoo
EOF
cd ..

# 6. Configure Odoo (Interactive)
cd odoo
./deploy.sh
# OR manually:
# cp .env.example .env
# Edit .env with your settings

# 7. Build and start everything
cd ..
./build-all.sh
./start-all.sh

# 8. Check status
docker ps
```

---

## 🔄 Common Commands

### Start All Services
```bash
./start-all.sh
```

### Stop All Services
```bash
./stop-all.sh
```

### Rebuild All Services
```bash
./build-all.sh
```

### View Logs
```bash
cd odoo && docker compose logs -f
cd traefik && docker compose logs -f
cd postgresql && docker compose logs -f
```

### Restart Odoo
```bash
cd odoo && docker compose restart
```

### Change Odoo Version/Branch
```bash
cd odoo
./deploy.sh
# OR edit .env and rebuild:
# docker compose down
# docker compose build --no-cache
# docker compose up -d
```

---

## 🌐 Access Your Services

- **Odoo**: `https://your-domain.com`
- **Traefik Dashboard**: `https://traefik.yourdomain.com:8080`

---

## 🆘 Quick Troubleshooting

### Container won't start?
```bash
docker compose logs
```

### Network errors?
```bash
docker network ls
docker network create traefik-network
docker network create postgres-network
```

### SSL not working?
```bash
# Check domain DNS
nslookup your-domain.com

# Check Traefik logs
cd traefik && docker compose logs -f
```

### Need to rebuild?
```bash
cd odoo
docker compose down
docker compose build --no-cache
docker compose up -d
```

---

## 📖 More Information

- **Full Documentation**: [README.md](README.md)
- **Deployment Guide**: [odoo/DEPLOYMENT_GUIDE.md](odoo/DEPLOYMENT_GUIDE.md)
- **Configuration Examples**: [odoo/.env.example](odoo/.env.example)

---

## 🎯 Popular Configurations

### Production Odoo 19.0
```env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0
```

### Development SaaS 18.4
```env
DEPLOYMENT_MODE=source
ODOO_BRANCH=saas-18.4
```

### Testing SaaS 17.4
```env
DEPLOYMENT_MODE=source
ODOO_BRANCH=saas-17.4
```

### Latest Development
```env
DEPLOYMENT_MODE=source
ODOO_BRANCH=master
```

---

**🚀 Ready to deploy? Start with `cd odoo && ./deploy.sh`**

# 🚀 Odoo Deployment Guide

## Quick Start

### Option 1: Interactive Setup (Recommended)
```bash
cd odoo
./deploy.sh
```

### Option 2: Manual Setup

#### A. Using Official Docker Image
```bash
# 1. Edit .env file
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0

# 2. Build and start
docker compose up -d --build
```

#### B. Using Git Clone (Specific Branch)
```bash
# 1. Edit .env file
DEPLOYMENT_MODE=source
ODOO_BRANCH=saas-18.4

# 2. Build and start
docker compose up -d --build
```

---

## 📖 Deployment Modes Explained

### Image Mode (Official Docker Images)
**When to use:**
- Production environments
- Stable releases
- Faster deployment
- Less disk space

**Supported versions:**
- 19.0, 18.0, 17.0, 16.0, 15.0, 14.0, etc.

**Configuration:**
```env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0
```

**Dockerfile used:** `Dockerfile.image`

---

### Source Mode (Git Clone)
**When to use:**
- Development environments
- Specific branches (e.g., saas-18.4)
- Custom repositories
- Latest features

**Supported branches:**
- `saas-18.4` - SaaS version 18.4
- `saas-17.4` - SaaS version 17.4
- `master` - Latest development
- `19.0`, `18.0`, `17.0` - Stable branches
- Any custom branch

**Configuration:**
```env
DEPLOYMENT_MODE=source
ODOO_REPO=https://github.com/odoo/odoo.git
ODOO_BRANCH=saas-18.4
```

**Dockerfile used:** `Dockerfile.source`

---

## 🔄 Common Operations

### Switch from Image to Source
```bash
# 1. Edit .env
DEPLOYMENT_MODE=source
ODOO_BRANCH=saas-18.4

# 2. Rebuild
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Switch from Source to Image
```bash
# 1. Edit .env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0

# 2. Rebuild
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Change Branch (Source Mode)
```bash
# 1. Edit .env
ODOO_BRANCH=saas-17.4

# 2. Rebuild
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Change Version (Image Mode)
```bash
# 1. Edit .env
ODOO_VERSION=18.0

# 2. Rebuild
docker compose down
docker compose build --no-cache
docker compose up -d
```

---

## 📝 Configuration Examples

### Example 1: Production ERP (Official Image)
```env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0
HOST=postgresql
USER=odoo
PASSWORD=SecurePassword123
DOMAIN=erp.mycompany.com
```

### Example 2: Development Environment (SaaS Branch)
```env
DEPLOYMENT_MODE=source
ODOO_REPO=https://github.com/odoo/odoo.git
ODOO_BRANCH=saas-18.4
HOST=postgresql
USER=odoo
PASSWORD=odoo
DOMAIN=dev.mycompany.com
```

### Example 3: Testing Custom Fork
```env
DEPLOYMENT_MODE=source
ODOO_REPO=https://github.com/mycompany/odoo-fork.git
ODOO_BRANCH=feature-new-module
HOST=postgresql
USER=odoo
PASSWORD=odoo
DOMAIN=test.mycompany.com
```

### Example 4: Multiple Domains
```env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0
HOST=postgresql
USER=odoo
PASSWORD=odoo
DOMAIN=`erp.company1.com`, `erp.company2.com`
```

---

## 🛠️ Useful Commands

### View Logs
```bash
docker compose logs -f
```

### Restart Container
```bash
docker compose restart
```

### Stop Container
```bash
docker compose down
```

### Rebuild from Scratch
```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Access Container Shell
```bash
docker compose exec odoo bash
```

### Check Container Status
```bash
docker compose ps
```

---

## 🐛 Troubleshooting

### Build Fails (Source Mode)
**Problem:** Git clone fails or build errors

**Solutions:**
1. Check branch name: `git ls-remote https://github.com/odoo/odoo.git | grep saas-18.4`
2. Verify internet connection
3. Check disk space: `df -h`
4. Try with `--no-cache`: `docker compose build --no-cache`

### Container Won't Start
**Problem:** Container exits immediately

**Solutions:**
1. Check logs: `docker compose logs`
2. Verify PostgreSQL is running: `docker ps | grep postgresql`
3. Check database credentials in `.env`
4. Verify networks exist: `docker network ls`

### Slow Build (Source Mode)
**Problem:** Source deployment takes too long

**Solutions:**
1. This is normal for first build (downloads entire Odoo source)
2. Subsequent builds use cache
3. Consider using image mode for faster deployment
4. Check internet speed

### Wrong Dockerfile Used
**Problem:** Build uses wrong Dockerfile

**Solutions:**
1. Check `DEPLOYMENT_MODE` in `.env`
2. Ensure no typos: must be exactly `image` or `source`
3. Rebuild with: `docker compose build --no-cache`

---

## 📊 Comparison Table

| Feature | Image Mode | Source Mode |
|---------|-----------|-------------|
| **Build Time** | Fast (~2-5 min) | Slow (~10-20 min) |
| **Disk Space** | Small (~2 GB) | Large (~5-8 GB) |
| **Flexibility** | Limited to releases | Any branch/commit |
| **Updates** | Pull new image | Git pull + rebuild |
| **Best For** | Production | Development |
| **Stability** | High | Varies by branch |
| **Customization** | Limited | Full access |

---

## 🔐 Security Best Practices

1. **Change default passwords** in `.env` file
2. **Use strong passwords** for production
3. **Keep Odoo updated** regularly
4. **Backup database** frequently
5. **Use HTTPS** (automatic with Traefik)
6. **Limit exposed ports** (only 80, 443)
7. **Review custom modules** before installation

---

## 📚 Additional Resources

- [Official Odoo Documentation](https://www.odoo.com/documentation)
- [Odoo GitHub Repository](https://github.com/odoo/odoo)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

---

## 💡 Tips & Tricks

### Tip 1: Use .env.example as Template
```bash
cp .env.example .env
# Edit .env with your configuration
```

### Tip 2: Check Available Branches
```bash
git ls-remote --heads https://github.com/odoo/odoo.git
```

### Tip 3: Monitor Resource Usage
```bash
docker stats odoo-odoo-1
```

### Tip 4: Quick Logs Check
```bash
docker compose logs --tail=50 -f
```

### Tip 5: Database Backup
```bash
docker exec postgresql-postgresql-1 pg_dump -U odoo odoo > backup.sql
```

---

## 🎯 Next Steps

After successful deployment:

1. **Access Odoo**: `https://your-domain.com`
2. **Create Database**: Use Odoo's database manager
3. **Install Modules**: Configure your ERP
4. **Setup Backups**: Implement backup strategy
5. **Monitor Performance**: Check logs and metrics
6. **Secure System**: Review security settings

---

**Need Help?** Check the main [README.md](../README.md) or open an issue on GitHub.

# 🐳 Odoo Docker Deployment

## 🎯 Two Deployment Modes Available

### 📦 Image Mode (Official Docker Images)
```
┌─────────────────────────────────────┐
│  Docker Hub                         │
│  ├── odoo:19.0                      │
│  ├── odoo:18.0                      │
│  └── odoo:17.0                      │
└─────────────────────────────────────┘
           ↓
    Dockerfile.image
           ↓
     Your Container
```

**Best for:**
- ✅ Production environments
- ✅ Stable releases
- ✅ Fast deployment (2-5 minutes)
- ✅ Less disk space (~2 GB)

**Configuration:**
```env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0
```

---

### 🔧 Source Mode (Git Clone)
```
┌─────────────────────────────────────┐
│  GitHub                             │
│  ├── saas-18.4                      │
│  ├── saas-17.4                      │
│  ├── master                         │
│  └── custom-branch                  │
└─────────────────────────────────────┘
           ↓
    git clone + build
           ↓
    Dockerfile.source
           ↓
     Your Container
```

**Best for:**
- ✅ Development environments
- ✅ Specific branches (saas-18.4)
- ✅ Latest features
- ✅ Custom repositories

**Configuration:**
```env
DEPLOYMENT_MODE=source
ODOO_REPO=https://github.com/odoo/odoo.git
ODOO_BRANCH=saas-18.4
```

---

## 🚀 Quick Start

### Option 1: Interactive (Recommended)
```bash
./deploy.sh
```

### Option 2: Manual Setup

**For Official Image:**
```bash
# Edit .env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0

# Deploy
docker compose up -d --build
```

**For Specific Branch:**
```bash
# Edit .env
DEPLOYMENT_MODE=source
ODOO_BRANCH=saas-18.4

# Deploy
docker compose up -d --build
```

---

## 📊 Comparison

| Feature | Image Mode | Source Mode |
|---------|-----------|-------------|
| Build Time | ⚡ 2-5 min | 🐌 10-20 min |
| Disk Space | 💾 ~2 GB | 💾 ~5-8 GB |
| Versions | 19.0, 18.0, 17.0... | Any branch |
| Updates | `docker pull` | `git pull` |
| Stability | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Flexibility | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 📖 Documentation

- **[Deployment Guide](DEPLOYMENT_GUIDE.md)** - Complete guide
- **[.env.example](.env.example)** - Configuration examples
- **[Main README](../README.md)** - Full documentation

---

## 🔄 Common Operations

### Switch Deployment Mode
```bash
# Edit .env to change DEPLOYMENT_MODE
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Change Version/Branch
```bash
# Edit .env to change ODOO_VERSION or ODOO_BRANCH
docker compose down
docker compose build --no-cache
docker compose up -d
```

### View Logs
```bash
docker compose logs -f
```

### Restart
```bash
docker compose restart
```

---

## 🎯 Popular Configurations

### Production (Odoo 19.0)
```env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0
DOMAIN=erp.mycompany.com
```

### Development (SaaS 18.4)
```env
DEPLOYMENT_MODE=source
ODOO_BRANCH=saas-18.4
DOMAIN=dev.mycompany.com
```

### Testing (Latest)
```env
DEPLOYMENT_MODE=source
ODOO_BRANCH=master
DOMAIN=test.mycompany.com
```

---

## 🆘 Need Help?

1. Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
2. View logs: `docker compose logs -f`
3. Rebuild: `docker compose build --no-cache`
4. Open an issue on GitHub

---

**Made with ❤️ for the Odoo community**

# Docker Traefik + Odoo (Multi-Version & Branch Support) + PostgreSQL

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Traefik](https://img.shields.io/badge/Traefik-v2.10-24A1C1?logo=traefikproxy&logoColor=white)](https://traefik.io/)
[![Odoo](https://img.shields.io/badge/Odoo-19.0-714B67?logo=odoo&logoColor=white)](https://www.odoo.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Complete production-ready stack with Traefik as reverse proxy, automatic SSL certificates with Let's Encrypt, PostgreSQL 17, and Odoo with flexible deployment options.

> **🚀 New to this project? Start here:** [**GET_STARTED.md**](GET_STARTED.md) - Deploy in 3 steps!

## ✨ Key Features

### 🎯 Dual Deployment Modes
- **📦 Image Mode**: Official Docker images (19.0, 18.0, 17.0, etc.) - Fast & stable
- **🔧 Source Mode**: Git clone from any branch (saas-18.4, saas-17.4, master) - Flexible & customizable

### 🚀 Easy Management
- **Interactive Setup**: Simple `./deploy.sh` script for configuration
- **One-Command Deployment**: Build and start with single commands
- **Automatic SSL**: Let's Encrypt certificates with auto-renewal
- **Multi-Domain Support**: Configure multiple domains easily

### 🛡️ Production Ready
- **Traefik Reverse Proxy**: Automatic HTTPS, load balancing, WebSocket support
- **PostgreSQL 17**: Latest database with persistent storage
- **Security**: SSL/TLS encryption, isolated networks, configurable passwords
- **Monitoring**: Easy log access and container management

## 📚 Documentation

- **[Summary](SUMMARY.md)** - Project overview and what's new 🎯
- **[Quick Start Guide](QUICK_START.md)** - Get started in 5 minutes ⚡
- **[Deployment Decision](DEPLOYMENT_DECISION.md)** - Choose the right deployment mode 🤔
- **[Deployment Guide](odoo/DEPLOYMENT_GUIDE.md)** - Detailed deployment instructions 📖
- **[Architecture Overview](ARCHITECTURE.md)** - System architecture and diagrams 🏗️
- **[Configuration Examples](odoo/.env.example)** - Sample configurations 📝
- **[YouTube Tutorial](YOUTUBE_TUTORIAL.md)** - Video tutorial reference 🎥
- **[Changelog](CHANGELOG.md)** - Version history and updates 📋

## 📋 Project Structure

```
docker-traefik/
├── traefik/                    # Reverse proxy with automatic SSL
├── postgresql/                 # PostgreSQL 17 database
├── odoo/                       # Odoo with multi-version & branch support
│   ├── deploy.sh              # Interactive deployment script
│   ├── Dockerfile.image       # For official Docker images
│   ├── Dockerfile.source      # For git clone deployment
│   ├── .env.example           # Configuration template
│   └── DEPLOYMENT_GUIDE.md    # Detailed guide
├── build-all.sh               # Script to build all services
├── start-all.sh               # Script to start all services
├── stop-all.sh                # Script to stop all services
├── QUICK_START.md             # Quick start guide
└── README.md                  # This file
```


## 🚀 Quick Start

### ⚡ One-Command Deployment

**Step 1:** Configure your `.env` files:

```bash
# traefik/.env
LETS_ENCRYPT_CONTACT_EMAIL=your-email@example.com
DOMAIN_NAME=`traefik.yourdomain.com`

# postgresql/.env
POSTGRES_DB=postgres
POSTGRES_PASSWORD=odoo
POSTGRES_USER=odoo

# odoo/.env (choose Image or Source mode)
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0
HOST=postgresql
USER=odoo
PASSWORD=odoo
DOMAIN=`odoo.yourdomain.com`
```

**Step 2:** Run the deployment script:

```bash
chmod +x deploy.sh && ./deploy.sh
```

**That's it!** 🎉 The script will automatically:
- ✅ Create Docker networks
- ✅ Configure Let's Encrypt
- ✅ Build all services
- ✅ Start everything
- ✅ Display deployment summary with longpolling status

---

### 📖 Manual Deployment (Alternative)

If you prefer step-by-step control:

#### 0. Install Docker (Optional)

If you don't have Docker installed, run the installation script with sudo:

```bash
sudo ./install-docker.sh
```

After installation, **log out and log back in** for the changes to take effect, or run:

```bash
newgrp docker
```

Then you can use Docker without sudo.

#### 1. Configure Docker Networks

```bash
docker network create traefik-network
docker network create postgres-network
```

#### 2. Configure Let's Encrypt Permissions

```bash
mkdir -p traefik/letsencrypt
touch traefik/letsencrypt/acme.json
chmod 600 traefik/letsencrypt/acme.json
```

#### 3. Configure Domains

Edit the `.env` files in each folder (see examples above).

**Note**: You can also use the interactive deployment script for Odoo: `cd odoo && ./deploy.sh`

#### 4. Build and Start Services

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
- **Odoo**: `https://demo.yourdomain.com`
  - Default user: `admin`
  - Master password (odoo.conf): `odooPassword`

## ⚙️ Domain Configuration

The project uses **environment variables** to manage domains, avoiding manual entry in multiple places.

### Change Odoo Domain

Simply edit the `odoo/.env` file:

```env
DOMAIN=new-domain.yourdomain.com
```

All Traefik routers (HTTP, HTTPS, websockets, etc.) will automatically use this domain.

### Change Traefik Domain

Edit the `traefik/.env` file:

```env
DOMAIN_NAME=`new-traefik.yourdomain.com`
```

### Change Odoo Version or Branch

#### Method 1: Interactive Script (Easiest)

```bash
cd odoo
./deploy.sh
```

This will guide you through:
- Choosing deployment mode (image or source)
- Selecting version or branch
- Building and starting the container

#### Method 2: Manual Configuration

**For Official Docker Image:**
```bash
# Edit odoo/.env
DEPLOYMENT_MODE=image
ODOO_VERSION=18.0  # or 17.0, 16.0, 15.0, etc.

# Rebuild
cd odoo
docker compose up -d --build
```

**For Specific Branch (e.g., saas-18.4):**
```bash
# Edit odoo/.env
DEPLOYMENT_MODE=source
ODOO_REPO=https://github.com/odoo/odoo.git
ODOO_BRANCH=saas-18.4  # or saas-17.4, master, etc.

# Rebuild
cd odoo
docker compose up -d --build
```

**Supported Options:**
- **Image Mode**: Any official Odoo Docker image (19.0, 18.0, 17.0, 16.0, 15.0, 14.0, etc.)
- **Source Mode**: Any branch from Odoo repository (saas-18.4, saas-17.4, master, etc.)

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

### Odoo (Multi-Version & Branch Support)
- **Default version**: 19.0 (configurable via `.env`)
- **Deployment modes**:
  - **Image**: Official Docker images (19.0, 18.0, 17.0, etc.)
  - **Source**: Git clone from repository (saas-18.4, saas-17.4, master, etc.)
- **Internal ports**: 8069 (HTTP), 8072 (WebSocket)
- **Features**:
  - **Flexible deployment**: Choose between official images or specific branches
  - **Interactive setup**: Use `./deploy.sh` for easy configuration
  - Proxy mode enabled
  - WebSocket for real-time chat
  - Special routes for `/web/database` and `/website/info`
  - Volumes:
    - `odoo-data`: Odoo data
    - `./extra-addons`: Custom modules
    - `./custom-addons`: Additional custom modules
    - `./odoo.conf`: Configuration

## 🚀 Deployment Examples

### Example 1: Production with Official Odoo 19.0
```bash
cd odoo
# Edit .env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0
DOMAIN=erp.mycompany.com

# Build and start
docker compose up -d --build
```

### Example 2: Development with SaaS 18.4 Branch
```bash
cd odoo
# Edit .env
DEPLOYMENT_MODE=source
ODOO_BRANCH=saas-18.4
DOMAIN=dev.mycompany.com

# Build and start
docker compose up -d --build
```

### Example 3: Testing Specific Branch from Custom Repository
```bash
cd odoo
# Edit .env
DEPLOYMENT_MODE=source
ODOO_REPO=https://github.com/mycompany/odoo-fork.git
ODOO_BRANCH=feature-custom-module
DOMAIN=test.mycompany.com

# Build and start
docker compose up -d --build
```

### Example 4: Using Interactive Deployment Script
```bash
cd odoo
./deploy.sh
# Follow the interactive prompts to configure and deploy
```

## 🔧 Useful Commands

### View service logs
```bash
cd traefik && docker compose logs -f
cd postgresql && docker compose logs -f
cd odoo && docker compose logs -f
```

### Restart a specific service
```bash
cd odoo && docker compose restart
```

### Rebuild a service
```bash
cd odoo && docker compose up -d --build
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

### Build fails with source deployment
- Check if the branch name is correct
- Verify repository URL is accessible
- Check available disk space (source build requires more space)
- View build logs: `cd odoo && docker compose build --no-cache`

### Switching between deployment modes
When switching from `image` to `source` or vice versa:
```bash
cd odoo
# Stop and remove current container
docker compose down
# Remove old image
docker compose build --no-cache
# Start with new configuration
docker compose up -d
```

---

## 📊 Deployment Mode Comparison

| Feature | Image Mode | Source Mode |
|---------|-----------|-------------|
| **Build Time** | ⚡ 2-5 minutes | 🐌 10-20 minutes |
| **Disk Space** | 💾 ~2 GB | 💾 ~5-8 GB |
| **Flexibility** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Stability** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Best For** | Production | Development |
| **Versions** | 19.0, 18.0, 17.0... | Any branch |
| **Updates** | `docker pull` | `git pull` + rebuild |
| **Customization** | Limited | Full access |

---

## 🌟 Community & Support

- **GitHub Repository**: [Mimbex/docker-traefik](https://github.com/Mimbex/docker-traefik)
- **Odoo Apps by Dustin**: [Browse Modules](https://apps.odoo.com/apps/modules/browse?author=Dustin)
- **Issues & Bug Reports**: [GitHub Issues](https://github.com/Mimbex/docker-traefik/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Mimbex/docker-traefik/discussions)

---

## 🎯 Quick Links

- 📖 [Full Documentation](SUMMARY.md)
- ⚡ [Quick Start](QUICK_START.md)
- 🏗️ [Architecture](ARCHITECTURE.md)
- 🎥 [YouTube Tutorial](YOUTUBE_TUTORIAL.md)
- 📋 [Changelog](CHANGELOG.md)

---

## 🙏 Acknowledgments

- **Odoo Community** - For the amazing ERP system
- **Traefik Team** - For the excellent reverse proxy
- **Docker Community** - For containerization technology
- **Contributors** - Everyone who helps improve this project

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 💖 Support the Project

If this project helps you, please consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting features
- 📖 Improving documentation
- 🔀 Contributing code

---

**Made with ❤️ by [Dustin Mimbela](https://github.com/Mimbex)**

**Happy Deploying! 🚀**
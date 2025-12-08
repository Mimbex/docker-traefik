# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2024-12-06

### 🎉 Major Features Added

#### Dual Deployment Mode Support
- **Image Mode**: Deploy using official Odoo Docker images (19.0, 18.0, 17.0, etc.)
- **Source Mode**: Deploy by cloning from Git repository (saas-18.4, saas-17.4, master, custom branches)

#### New Files Created
- `odoo/Dockerfile.image` - Dockerfile for official Docker image deployment
- `odoo/Dockerfile.source` - Dockerfile for git clone deployment
- `odoo/entrypoint.sh` - Custom entrypoint script for source deployments
- `odoo/deploy.sh` - Interactive deployment configuration script
- `odoo/.env.example` - Comprehensive configuration template
- `odoo/DEPLOYMENT_GUIDE.md` - Detailed deployment documentation
- `odoo/README.md` - Odoo-specific documentation
- `QUICK_START.md` - Quick start guide for new users
- `ARCHITECTURE.md` - System architecture documentation
- `CHANGELOG.md` - This file

#### Enhanced Configuration
- Updated `odoo/.env` with deployment mode options
- Added support for custom Git repositories
- Added support for specific branch deployment (e.g., saas-18.4)
- Multi-domain support maintained

#### Updated Documentation
- Enhanced main `README.md` with new features
- Added deployment examples
- Added troubleshooting for branch deployment
- Created comprehensive guides

### 🔧 Technical Changes

#### Docker Compose
- Updated `odoo/docker-compose.yml` to support dynamic Dockerfile selection
- Added build arguments for repository and branch configuration
- Maintained backward compatibility with existing deployments

#### Dockerfiles
- **Dockerfile.image**: Optimized for official images with custom dependencies
- **Dockerfile.source**: Complete build from source with all dependencies
- Both support the same volume structure and configuration

### 📚 Documentation Improvements
- Added visual architecture diagrams
- Created deployment flow charts
- Added comparison tables (Image vs Source mode)
- Included practical examples for common scenarios

### ✨ User Experience
- Interactive deployment script with colored output
- Step-by-step configuration wizard
- Clear error messages and troubleshooting
- Multiple deployment examples

### 🔄 Migration Guide

#### From Previous Version
If you're upgrading from a previous version:

1. **Backup your data**:
   ```bash
   docker exec postgresql-postgresql-1 pg_dump -U odoo odoo > backup.sql
   ```

2. **Update configuration**:
   ```bash
   cd odoo
   cp .env .env.backup
   # Add new configuration options
   echo "DEPLOYMENT_MODE=image" >> .env
   ```

3. **Rebuild (optional)**:
   ```bash
   docker compose down
   docker compose build --no-cache
   docker compose up -d
   ```

### 🎯 Use Cases

#### Production Deployment
```env
DEPLOYMENT_MODE=image
ODOO_VERSION=19.0
```

#### Development with SaaS Branch
```env
DEPLOYMENT_MODE=source
ODOO_BRANCH=saas-18.4
```

#### Custom Repository
```env
DEPLOYMENT_MODE=source
ODOO_REPO=https://github.com/mycompany/odoo-fork.git
ODOO_BRANCH=custom-feature
```

### 🐛 Bug Fixes
- Fixed Dockerfile permissions for odoo.conf
- Improved error handling in deployment scripts
- Enhanced network configuration documentation

### 📊 Performance
- Image mode: ~2-5 minutes build time
- Source mode: ~10-20 minutes build time (first build)
- Subsequent builds use Docker cache for faster deployment

---

## [1.0.0] - Previous Version

### Features
- Traefik reverse proxy with automatic SSL
- PostgreSQL 17 database
- Odoo deployment with official Docker images
- Multi-version support via ODOO_VERSION
- Automatic HTTPS with Let's Encrypt
- WebSocket support
- Management scripts (build-all.sh, start-all.sh, stop-all.sh)

---

## Upgrade Instructions

### To 2.0.0

**No breaking changes** - The new version is fully backward compatible.

**Optional upgrade steps**:

1. Pull latest changes:
   ```bash
   git pull origin main
   ```

2. Review new configuration options:
   ```bash
   cat odoo/.env.example
   ```

3. Try the interactive deployment:
   ```bash
   cd odoo
   ./deploy.sh
   ```

**Existing deployments will continue to work without changes.**

---

## Future Roadmap

- [ ] Support for Odoo Enterprise edition
- [ ] Automated backup scripts
- [ ] Monitoring and alerting integration
- [ ] Multi-instance deployment support
- [ ] Kubernetes deployment option
- [ ] CI/CD pipeline examples

---

## Contributing

Contributions are welcome! Please read the documentation before submitting pull requests.

## Support

- GitHub Issues: [https://github.com/Mimbex/docker-traefik/issues](https://github.com/Mimbex/docker-traefik/issues)
- Documentation: See README.md and guides in the repository

---

**Made with ❤️ for the Odoo community**

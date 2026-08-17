# Web Server — Linux SysAdmin Project Proposal

**Submitted by:** @ammdevl

**Date of Submission:** 2026-08-17

**Target Environment:** Ubuntu 24.04 LTS (Online VPS)

## Gist

A secure Apache2 web server hosting a Next.js application on an online VPS, accessed via the VPS's public IP address, with proper user/group management, file permissions, and SSL/TLS encryption.

## Story

A student builds a personal portfolio using Next.js and deploys it on a VPS so it's accessible from anywhere via the server's public IP. Without proper Linux administration, the app runs as root with wide-open permissions — anyone on the server can read, modify, or delete critical files. By applying user and group management, the student creates dedicated accounts for deployment and administration, restricts file access to the right people, and hardens the server so only authorized users can manage the site.

## Why

- Deploys the Next.js app on a real VPS, making it publicly accessible via the server's IP address.
- Applies lecture concepts — user accounts, groups, and file permissions — in a real-world scenario.
- Ensures least-privilege access: the web server process, the deployer, and the admin each have their own restricted permissions.

## Why Not

- No domain registration — access is via the VPS public IP only.
- No load balancing or clustering — single VPS for learning purposes.
- No containerization (Docker/Podman) — bare-metal setup to understand the underlying services.
- No CMS or database — the site is a standalone Next.js application.
- No CI/CD pipeline — deployment is done manually via SSH for direct learning.

## Tech Spec

- **OS / Distro:** Ubuntu 24.04 LTS (Online VPS)
- **Core Services & Packages:**
  - `apache2` — web server and reverse proxy
  - `libapache2-mod-proxy-http` — Apache reverse proxy module
  - `nodejs` + `npm` — runtime for Next.js
  - `certbot` + `python3-certbot-apache` — SSL/TLS certificate management
  - `ufw` — firewall
  - `fail2ban` — intrusion prevention, bans IPs after repeated failed attempts
- **User & Group Management:**
  - `sysadmin` group — full sudo access for server administration
  - `dev` group — deployment access, owns and manages web files
  - Apache runs under `www-data` (system default, not customized)
  - Default accounts (`root` excluded) locked or removed
- **File & Directory Permissions:**
  - `/var/www/app/` — owned by `deployer:dev`, `775` directories, `664` files
  - `dev` group has read/write access to web files
  - `sysadmin` group has full access to all server configs
  - SSH keys restricted — no password login, key-only authentication
  - Sensitive config files (`.env`, SSL keys) readable only by root or `sysadmin` group
  - Web server cannot write to its own document root (defense against compromise)
- **Automation / Config:**
  - Bash script for server setup, user creation, permission configuration, and Apache setup
  - Config templates stored in the repository for consistent deployments
- **Architecture / Flow:**
  ```
  Client (browser) → HTTPS (<vps-ip>:443) → Apache2 (TLS termination)
      → Reverse Proxy (ProxyPass) → Next.js (Node.js, port 3000)
      → Static assets served directly by Apache

  SSH (22) → deployer user → git pull → npm run build → restart Next.js
  ```
  - Access: `https://<vps-public-ip>` (no domain name)
  - Next.js runs on `localhost:3000` managed by `systemd` as dedicated user
  - Apache proxies all requests to the Node.js process
  - All file operations logged and permission-restricted

## Security & Backup Plan

- UFW allows only SSH (22), HTTP (80), and HTTPS (443) — all other ports blocked.
- SSH hardened: key-only auth, root login disabled, port changed from default.
- fail2ban monitors SSH and Apache logs — auto-bans IPs after 5 failed attempts for 1 hour.
- Apache configured with `ServerTokens Prod` and `ServerSignature Off` to hide version info.
- Dedicated system user for Next.js process — not running as root.
- File permissions enforce least-privilege — web server cannot modify its own files.
- SSL hardened with TLS 1.2/1.3 only, strong cipher suites, and HSTS headers.
- `.env` and config files readable only by their dedicated owner.
- Regular backups of config and app source to the repository.

## Definition of Done

- [ ] VPS is accessible via SSH with key-only authentication (no password login).
- [ ] `sysadmin` and `dev` groups created with appropriate members.
- [ ] Dedicated `developers` (in `dev`) and `admins` (in `sysadmin`) users created.
- [ ] Root login is disabled over SSH.
- [ ] Apache2 installs and starts without errors (`systemctl status apache2` shows active).
- [ ] Next.js app builds and runs on `localhost:3000` as a dedicated non-root user.
- [ ] `curl http://<vps-ip>` returns the Next.js page via Apache reverse proxy.
- [ ] HTTPS works — `curl -I https://<vps-ip>` returns `200` with valid certificate.
- [ ] HTTP-to-HTTPS redirect is in place.
- [ ] File permissions are correct — `ls -la /var/www/app/` shows proper ownership.
- [ ] Web server process cannot write to its own document root.
- [ ] Firewall blocks all ports except 22, 80, and 443.
- [ ] fail2ban is active and monitoring SSH and Apache (`fail2ban-client status`).
- [ ] Server version info is hidden in HTTP response headers.
- [ ] Both Apache and Next.js services survive a VPS reboot.

## Key References & Documentation

- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [Apache2 Documentation](https://httpd.apache.org/docs/2.4/)
- [Apache mod_proxy Documentation](https://httpd.apache.org/docs/2.4/mod/mod_proxy.html)
- [Next.js Deployment Guide](https://nextjs.org/docs/deploying)
- [Certbot Apache Plugin](https://certbot.eff.org/instructions?ws=apache&os=ubuntunoble)
- [Ubuntu UFW Guide](https://help.ubuntu.com/community/UFW)
- [Linux File Permissions Guide](https://www.linuxfoundation.org/blog/linux-file-permissions)
- [Ubuntu User Management](https://ubuntu.com/server/docs/user-management)

Hardened LEMP Web Stack & Benchmarking — Linux SysAdmin Project Proposal
Submitted by: @aungmyintmyataung246-eng

Date of Submission: 2026-08-18

Target Environment: Ubuntu 26.04 LTS

Gist
Deploying, hardening, and performance-benchmarking a production-ready LEMP stack (Linux, Nginx, MariaDB, PHP-FPM) on Ubuntu 24.04 LTS, featuring automated shell backups, host-based firewalls, intrusion prevention, and SSL/TLS encryption.

Story
Standard Linux server installations often ship with default configurations optimized for compatibility rather than security or speed. In production, unhardened web servers are frequent targets for brute-force attacks, resource exhaustion, and unauthorized access.

This project simulates a real-world Systems Administrator assignment: building a high-concurrency web server environment from the ground up using the command line, locking down system entry points against attack vectors, and measuring performance gains achieved through configuration tuning.

Why
Core Competency: Demonstrates hands-on proficiency in Linux system administration, networking, and service management (systemd).

Security & Compliance: Implements defense-in-depth principles (SSH key authentication, firewall state tracking, brute-force mitigation).

Performance Optimization: Explores how asynchronous web servers (Nginx) and FastCGI process managers (PHP-FPM) handle heavy concurrent loads compared to default setups.

Automation & Maintenance: Establishes repeatable backup routines and system monitoring using Bash automation.

Why Not
Why not Apache? Apache’s process-per-request model consumes significantly more memory under heavy concurrent traffic. Nginx uses an event-driven, asynchronous architecture that handles high request volumes with a lower memory footprint.

Why not Docker / Containers? While containers are widely used, running services directly on the host OS (bare-metal or VM) is essential for mastering Linux kernel concepts, systemd service management, user permissions, and host networking.

Why not a managed PaaS (e.g., Vercel / Heroku)? Fully managed platforms hide the underlying operating system. Configuring an unmanaged Linux server builds foundational infrastructure skills required for enterprise sysadmin and DevOps roles.

Tech Spec
OS / Distro: Ubuntu Server 26.04 LTS

Core Services & Packages:

Web Daemon: nginx

Database Engine: mariadb-server

Application Runtime: php8.3-fpm, php-mysql

Security Utilities: ufw, fail2ban, certbot, openssl

Benchmarking & Diagnostic Tools: apache2-utils (ab), htop, net-tools

Automation / Config:

Custom Bash shell scripts for database dumps and web file archiving.

System cron jobs for daily backup execution and log management (logrotate).

Security & Backup Plan
SSH Hardening: Disable SSH password authentication (enforce 2048-bit+ SSH keys), disable remote root login, and change default listening behavior.

Network Security (UFW): Set default incoming policy to DROP. Explicitly allow only ports 80 (HTTP), 443 (HTTPS), and custom SSH ports.

Intrusion Prevention (Fail2ban): Monitor authentication logs (/var/log/auth.log) to automatically ban IP addresses demonstrating repeated failed login attempts.

SSL/TLS Encryption: Generate and bind domain SSL/TLS certificates via Let's Encrypt (certbot) with automated renewal testing.

Backup Strategy:

Automated nightly Cron job executing mysqldump for database schema and data preservation.

Compressed .tar.gz archiving of web site files (/var/www/html/) stored in a separate backup partition (/var/backups/).

Definition of Done
[ ] Ubuntu 26.04 LTS server provisioned with functional LEMP stack serving dynamic content over HTTPS.

[ ] System security baseline active: SSH key-only access enforced, UFW active, and Fail2ban jail rules running.

[ ] Automated Bash backup script created, tested for restoration, and scheduled via System Cron.

[ ] Load testing executed via ApacheBench (ab), with baseline vs. optimized performance metrics recorded in the final project report.

Key References & Documentation
Ubuntu Server Guide

Nginx Official Documentation

MariaDB Knowledge Base

PHP-FPM Documentation

DigitalOcean Ubuntu 24.04 Initial Server Setup Guide

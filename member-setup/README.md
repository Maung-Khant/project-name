## Linux System Administration - Project Setup

A Bash script that installs essential system administration tools and configures Git on Ubuntu.

## Prerequisites

- **Operating System:** Ubuntu 22.04 LTS or later
- **Git:** Must be pre-installed (`sudo apt-get install git`)
- **Internet:** Required for package downloads
- **Privileges:** `sudo` access

## What Gets Installed

### Core Utilities
`vim` `nano` `tmux` `tree` `curl` `wget` `unzip` `p7zip-full` `bash-completion`

### Process & System Monitoring
`htop` `sysstat` `procps` `psmisc`

### Networking
`net-tools` `iputils-ping` `traceroute` `mtr-tiny` `nmap` `netcat-openbsd` `dnsutils` `tcpdump` `openssh-client`

### Disk & Storage
`lsof` `ncdu` `parted` `smartmontools`

### System Info & Tracing
`strace` `lsb-release` `lshw` `file`

### User & Security
`openssh-server` `fail2ban` `ufw`

### Services & Logging
`cron` `logrotate` `rsyslog`

### Compression
`tar` `gzip` `bzip2` `xz-utils`

### DHCP Server
`isc-dhcp-server`

### DNS Server
`bind9` `bind9utils` `bind9-doc`

### Web Server
`nginx` `certbot` `python3-certbot-nginx` `openssl`

### VPN Server
`wireguard` `openvpn` `easy-rsa`

### Proxy Server
`squid` `squid-common`

### Mail Server
`postfix` `dovecot-core` `dovecot-imapd` `dovecot-pop3d` `mailutils`

### SSL/TLS & Transport
`ca-certificates` `apt-transport-https`

## Git Configuration

The script also configures your global Git settings (user name, email, defaults, etc.). Existing values are preserved and skipped.

## Usage

```bash
# Clone and run
git clone https://github.com/<your-github-username>/project-name.git
cd project-name/member-setup
chmod +x setup.sh
./setup.sh
```

## Verifying Your Setup

After running the script, verify your global Git settings:

```bash
git config --list --global
```

Check installed tools:

```bash
htop --version
nmap --version
ufw status
```

---

<div align="center">
  <sub>Built with ❤️ during our academic journey</sub>
</div>

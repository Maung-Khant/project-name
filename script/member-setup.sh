#!/usr/bin/env bash

set -e

# =============================================================================
# Linux System Administration - Project Setup Script
# Target: Ubuntu (22.04 LTS or later)
# =============================================================================

# --- Ctrl+C Handler ---
abort_install() {
    echo ""
    echo -e "  ${RED}! Installation aborted by user.${RESET}"
    echo ""
    exit 1
}
trap abort_install SIGINT SIGTERM

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# --- Animation Helpers ---
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='-\|/'
    while kill -0 "$pid" 2>/dev/null; do
        for (( i=0; i<${#spinstr}; i++ )); do
            printf "\r  ${CYAN}%s${RESET} Installing..." "${spinstr:$i:1}"
            sleep "$delay"
        done
    done
    printf "\r"
}

progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percent=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))

    printf "\r  ["
    printf "${GREEN}%.0s#${RESET}" $(seq 1 $filled 2>/dev/null) || true
    printf "${DIM}%.0s-${RESET}" $(seq 1 $empty 2>/dev/null) || true
    printf "] ${BOLD}%3d%%${RESET} (${current}/${total})" "$percent"
}

section_header() {
    local title="$1"
    local icon="$2"
    echo ""
    echo -e "  ${BLUE}------------------------------------------------------------${RESET}"
    echo -e "  ${BOLD}  ${icon}  ${title}${RESET}"
    echo -e "  ${BLUE}------------------------------------------------------------${RESET}"
    echo ""
}

print_banner() {
    local ubuntu_ver
    ubuntu_ver=$(lsb_release -rs 2>/dev/null || echo 'unknown')
    local title="Linux System Administration Setup"
    local subtitle="Target: Ubuntu ${ubuntu_ver}"
    local border="------------------------------------------------------------"
    echo ""
    echo -e "  ${CYAN}+${border}+${RESET}"
    echo -e "  ${CYAN}|${RESET}  ${BOLD}${title}${RESET}"
    echo -e "  ${CYAN}|${RESET}  ${DIM}${subtitle}${RESET}"
    echo -e "  ${CYAN}+${border}+${RESET}"
    echo ""
}

# --- Prerequisite Checks ---
check_ubuntu() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "ubuntu" ]; then
            echo -e "  ${RED}✗ Error: This script is designed for Ubuntu only.${RESET}"
            echo -e "  ${DIM}Detected: $PRETTY_NAME${RESET}"
            exit 1
        fi
    else
        echo -e "  ${RED}✗ Error: Cannot detect OS. /etc/os-release not found.${RESET}"
        exit 1
    fi
}

check_git() {
    if ! command -v git &> /dev/null; then
        echo -e "  ${RED}✗ Error: git is not installed.${RESET}"
        echo -e "  ${DIM}Please install git first: sudo apt-get install git${RESET}"
        exit 1
    fi
    echo -e "  ${GREEN}✓${RESET} Git detected: $(git --version)"
}

# --- System Tools to Install ---
# Grouped by category for clarity
TOOLS=(
    # Core utilities
    vim
    nano
    tmux
    tree
    curl
    wget
    unzip
    p7zip-full
    bash-completion

    # Process & system monitoring
    htop
    sysstat
    procps
    psmisc

    # Networking
    net-tools
    iputils-ping
    traceroute
    mtr-tiny
    nmap
    netcat-openbsd
    dnsutils
    tcpdump
    openssh-client

    # Disk & storage
    lsof
    ncdu
    parted
    smartmontools

    # System info & tracing
    strace
    lsb-release
    lshw
    file

    # User & security
    openssh-server
    fail2ban
    ufw

    # Services & logging
    cron
    logrotate
    rsyslog

    # Compression & archives
    tar
    gzip
    bzip2
    xz-utils

    # === Server-Specific Packages ===

    # DHCP Server
    isc-dhcp-server

    # DNS Server
    bind9
    bind9utils
    bind9-doc

    # Web Server
    nginx
    certbot
    python3-certbot-nginx
    openssl

    # VPN Server
    wireguard
    openvpn
    easy-rsa

    # Proxy Server
    squid
    squid-common

    # Mail Server
    postfix
    dovecot-core
    dovecot-imapd
    dovecot-pop3d
    mailutils

    # SSL/TLS Certificate Tools
    ca-certificates
    apt-transport-https
)

# --- Install Tools ---
install_tools() {
    section_header "Installing System Administration Tools" "⚙️"

    sudo apt-get update -qq 2>/dev/null
    echo -e "  ${GREEN}✓${RESET} Package lists updated"
    echo ""

    # Preconfigure interactive packages to avoid debconf prompts
    echo -e "  ${DIM}Preconfiguring interactive packages...${RESET}"
    sudo debconf-set-selections <<< "postfix postfix/main_mailer_type select Internet Site"
    sudo debconf-set-selections <<< "postfix postfix/mailname string $(hostname -f 2>/dev/null || hostname)"
    sudo debconf-set-selections <<< "postfix postfix/kernel_version string $(uname -r)"

    local total=${#TOOLS[@]}
    local installed=0
    local skipped=0
    local current=0

    for tool in "${TOOLS[@]}"; do
        current=$((current + 1))
        if dpkg -s "$tool" &> /dev/null; then
            echo -e "  ${DIM}o ${tool}${RESET} ${YELLOW}(already installed)${RESET}"
            skipped=$((skipped + 1))
        else
            echo -e "  ${CYAN}>${RESET} ${tool}..."
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$tool" > /dev/null 2>&1
            echo -e "  ${GREEN}+${RESET} ${tool} installed"
            installed=$((installed + 1))
        fi
        progress_bar $current $total
        echo ""
    done

    echo ""
    echo ""
    echo -e "  ${GREEN}------------------------------------------------------------${RESET}"
    echo -e "  ${BOLD}  Results: ${GREEN}${installed} installed${RESET}  ${YELLOW}${skipped} skipped${RESET}  ${DIM}${total} total${RESET}"
    echo -e "  ${GREEN}------------------------------------------------------------${RESET}"
}

# --- Git Configuration Helpers ---
set_config_if_missing() {
    local key="$1"
    local value="$2"

    if git config --global --get "$key" &> /dev/null; then
        local current_val
        current_val=$(git config --global --get "$key")
        echo -e "  ${DIM}○${RESET} '${key}' ${YELLOW}already set${RESET} → ${DIM}${current_val}${RESET}"
    else
        git config --global "$key" "$value"
        echo -e "  ${GREEN}✓${RESET} '${key}' ${GREEN}set${RESET} → ${BOLD}${value}${RESET}"
    fi
}

configure_user_credentials() {
    # user.name
    if git config --global --get user.name &> /dev/null; then
        local current_name
        current_name=$(git config --global --get user.name)
        echo -e "  ${DIM}○${RESET} 'user.name' ${YELLOW}already set${RESET} → ${DIM}${current_name}${RESET}"
    else
        read -rp "  Enter your name: " USER_NAME
        if [ -n "$USER_NAME" ]; then
            git config --global user.name "$USER_NAME"
            echo -e "  ${GREEN}✓${RESET} 'user.name' ${GREEN}set${RESET} → ${BOLD}${USER_NAME}${RESET}"
        fi
    fi

    # user.email
    if git config --global --get user.email &> /dev/null; then
        local current_email
        current_email=$(git config --global --get user.email)
        echo -e "  ${DIM}○${RESET} 'user.email' ${YELLOW}already set${RESET} → ${DIM}${current_email}${RESET}"
    else
        read -rp "  Enter your email associated with github: " USER_EMAIL
        if [ -n "$USER_EMAIL" ]; then
            git config --global user.email "$USER_EMAIL"
            echo -e "  ${GREEN}✓${RESET} 'user.email' ${GREEN}set${RESET} → ${BOLD}${USER_EMAIL}${RESET}"
        fi
    fi
}

apply_git_configurations() {
    section_header "Checking & Applying Git Configurations" "🔧"

    configure_user_credentials

    set_config_if_missing "init.defaultBranch" "main"
    set_config_if_missing "core.autocrlf" "input"
    set_config_if_missing "core.editor" "code --wait"
    set_config_if_missing "push.default" "simple"
    set_config_if_missing "fetch.prune" "true"
    set_config_if_missing "rerere.enabled" "true"
    set_config_if_missing "diff.algorithm" "histogram"
    set_config_if_missing "diff.tool" "vscode"
    set_config_if_missing "difftool.vscode.cmd" 'code --wait --diff "$LOCAL" "$REMOTE"'
    set_config_if_missing "merge.tool" "vscode"
    set_config_if_missing "mergetool.vscode.cmd" 'code --wait "$MERGED"'
    set_config_if_missing "credential.helper" "manager"
    set_config_if_missing "format.pretty" "%h %ad | %s%d [%an]"
    set_config_if_missing "log.date" "short"
    set_config_if_missing "commit.gpgsign" "true"
    set_config_if_missing "pull.rebase" "false"

    echo ""
    echo -e "  ${GREEN}✓${RESET} Git configuration check complete!"
}

# --- Main Entry Point ---
print_banner

check_ubuntu
check_git

install_tools
apply_git_configurations

echo ""
BORDER="------------------------------------------------------------"
echo -e "  ${CYAN}+${BORDER}+${RESET}"
echo -e "  ${CYAN}|${RESET}  ${BOLD}${GREEN}+ Setup Complete!${RESET}"
echo -e "  ${CYAN}|${RESET}  ${DIM}Installed ${#TOOLS[@]} system administration tools.${RESET}"
echo -e "  ${CYAN}|${RESET}  ${DIM}Run 'git config --list --global' to review settings.${RESET}"
echo -e "  ${CYAN}+${BORDER}+${RESET}"
echo ""

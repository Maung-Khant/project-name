#!/usr/bin/env bash

set -e

# =============================================================================
# Linux System Administration - Project Setup Script
# Target: Ubuntu (22.04 LTS or later)
# =============================================================================

# --- Prerequisite Checks ---
check_ubuntu() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "ubuntu" ]; then
            echo "Error: This script is designed for Ubuntu only."
            echo "Detected: $PRETTY_NAME"
            exit 1
        fi
    else
        echo "Error: Cannot detect OS. /etc/os-release not found."
        exit 1
    fi
}

check_git() {
    if ! command -v git &> /dev/null; then
        echo "Error: git is not installed."
        echo "Please install git first: sudo apt-get install git"
        exit 1
    fi
    echo "Git detected: $(git --version)"
}

check_ubuntu
check_git

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
)

# --- Install Tools ---
install_tools() {
    echo ""
    echo "--- Installing System Administration Tools ---"
    echo ""

    sudo apt-get update -qq

    local installed=0
    local skipped=0

    for tool in "${TOOLS[@]}"; do
        if dpkg -s "$tool" &> /dev/null; then
            echo "  [SKIP] $tool (already installed)"
            skipped=$((skipped + 1))
        else
            echo "  [INST] $tool"
            sudo apt-get install -y -qq "$tool" > /dev/null
            installed=$((installed + 1))
        fi
    done

    echo ""
    echo "Tools: $installed installed, $skipped already present"
}

# --- Git Configuration Helpers ---
set_config_if_missing() {
    local key="$1"
    local value="$2"

    if git config --global --get "$key" &> /dev/null; then
        local current_val
        current_val=$(git config --global --get "$key")
        echo "  [SKIP] '$key' is already set to '$current_val'"
    else
        git config --global "$key" "$value"
        echo "  [SET]  '$key' = '$value'"
    fi
}

configure_user_credentials() {
    # user.name
    if git config --global --get user.name &> /dev/null; then
        local current_name
        current_name=$(git config --global --get user.name)
        echo "  [SKIP] 'user.name' is already set to '$current_name'"
    else
        read -rp "Enter your name: " USER_NAME
        if [ -n "$USER_NAME" ]; then
            git config --global user.name "$USER_NAME"
            echo "  [SET]  'user.name' = '$USER_NAME'"
        fi
    fi

    # user.email
    if git config --global --get user.email &> /dev/null; then
        local current_email
        current_email=$(git config --global --get user.email)
        echo "  [SKIP] 'user.email' is already set to '$current_email'"
    else
        read -rp "Enter your email associated with github: " USER_EMAIL
        if [ -n "$USER_EMAIL" ]; then
            git config --global user.email "$USER_EMAIL"
            echo "  [SET]  'user.email' = '$USER_EMAIL'"
        fi
    fi
}

apply_git_configurations() {
    echo ""
    echo "--- Checking & Applying Git Configurations ---"

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
    echo "Git configuration check complete!"
}

# --- Main Entry Point ---
echo "=== Linux System Administration Setup ==="
echo "Target: Ubuntu $(lsb_release -rs 2>/dev/null || echo 'unknown')"
echo ""

install_tools
apply_git_configurations

echo ""
echo "=== Setup Complete ==="
echo "Installed ${#TOOLS[@]} system administration tools."
echo "Run 'git config --list --global' to review your git settings."

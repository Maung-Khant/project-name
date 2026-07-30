#!/usr/bin/env bash

set -e

# Detect OS platform
detect_os() {
    case "$OSTYPE" in
        linux*)   echo "linux" ;;
        darwin*)  echo "macos" ;;
        msys*|cygwin*|mingw*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# --- macOS Handlers ---
ensure_homebrew_macos() {
    if command -v brew &> /dev/null; then
        echo "Homebrew is already installed."
    else
        echo "--> Homebrew is not installed. Downloading and installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
}

ensure_macos_prerequisites() {
    ensure_homebrew_macos

    if command -v wget &> /dev/null; then
        echo "wget is already installed."
    else
        echo "--> wget is not installed. Downloading and installing wget via Homebrew..."
        brew install wget
    fi

    if command -v git &> /dev/null; then
        echo "Git is already installed ($(git --version))."
    else
        echo "--> Git is not installed. Downloading and installing Git via Homebrew..."
        brew install git
    fi
}

# --- Linux Handlers ---
ensure_linux_prerequisites() {
    # Detect Linux Package Manager
    local PKG_MANAGER=""
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
    elif command -v zypper &> /dev/null; then
        PKG_MANAGER="zypper"
    else
        echo "Error: Could not identify native Linux package manager."
        exit 1
    fi

    # Check / Install Git
    if command -v git &> /dev/null; then
        echo "Git is already installed ($(git --version))."
    else
        echo "--> Git is not installed. Downloading and installing Git via ${PKG_MANAGER}..."
        case "$PKG_MANAGER" in
            apt)    sudo apt-get update && sudo apt-get install -y git ;;
            dnf)    sudo dnf install -y git ;;
            yum)    sudo yum install -y git ;;
            pacman) sudo pacman -S --noconfirm git ;;
            zypper) sudo zypper install -y git ;;
        esac
    fi
}

# --- Windows Handlers ---
ensure_windows_prerequisites() {
    # Check / Install wget
    if command -v wget &> /dev/null; then
        echo "wget is already installed."
    else
        echo "--> wget is not installed. Downloading and installing wget..."
        if command -v winget &> /dev/null; then
            winget install --id GNU.Wget -e --source winget
        elif command -v choco &> /dev/null; then
            choco install wget -y
        else
            echo "Error: Neither winget nor chocolatey found to install wget."
            exit 1
        fi
    fi

    # Check / Install Git
    if command -v git &> /dev/null; then
        echo "Git is already installed ($(git --version))."
    else
        echo "--> Git is not installed. Downloading and installing Git..."
        if command -v winget &> /dev/null; then
            winget install --id Git.Git -e --source winget
        elif command -v choco &> /dev/null; then
            choco install git -y
        else
            echo "Error: Neither winget nor chocolatey found to install Git."
            exit 1
        fi
    fi
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

apply_configurations() {
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
echo "=== System Prerequisite Checks ==="

OS="$(detect_os)"

case "$OS" in
    macos)
        ensure_macos_prerequisites
        ;;
    linux)
        ensure_linux_prerequisites
        ;;
    windows)
        ensure_windows_prerequisites
        ;;
    *)
        echo "Error: Unsupported operating system ($OSTYPE)."
        exit 1
        ;;
esac

apply_configurations
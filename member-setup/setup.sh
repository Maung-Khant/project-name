#!/usr/bin/env bash

set -e

# --- Prerequisite Check ---
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed."
    echo "Please install git before running this script."
    echo "  - macOS:   brew install git"
    echo "  - Linux:   sudo apt-get install git  (or your distro's equivalent)"
    echo "  - Windows: winget install --id Git.Git -e --source winget"
    exit 1
fi

echo "Git detected: $(git --version)"

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
echo "=== Git Configuration Setup ==="

apply_configurations
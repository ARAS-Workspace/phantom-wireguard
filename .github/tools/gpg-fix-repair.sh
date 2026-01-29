#!/bin/bash
# ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗
# ██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║
# ██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║
# ██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║
# ██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║
# ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝
# Copyright (c) 2025 Rıza Emre ARAS <r.emrearas@proton.me>
# =============================================================================
# GPG Fix & Repair Script for macOS
# This script automatically detects and fixes GPG/Git signing issues
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Default primary key (can be overridden by parameter)
PRIMARY_KEY="${1:-}"

log() {
    echo -e "${2:-$NC}[$(date '+%H:%M:%S')] $1${NC}"
}

# Print header
print_header() {
    echo -e "${CYAN}"
    echo "██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗"
    echo "██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║"
    echo "██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║"
    echo "██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║"
    echo "██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║"
    echo "╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝"
    echo -e "${NC}"
    echo -e "${CYAN}Copyright (c) 2025 Rıza Emre ARAS <r.emrearas@proton.me>${NC}"
    echo -e "${WHITE}GPG Fix & Repair Script for macOS${NC}"
    echo ""
}

# Function to show help
show_help() {
    print_header
    echo -e "${BLUE}GPG Fix & Repair Script for macOS${NC}"
    echo ""
    echo "This script automatically detects and fixes GPG/Git signing issues on macOS."
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "    $0 [GPG_KEY_ID]"
    echo "    $0 --help | -h"
    echo ""
    echo -e "${YELLOW}Arguments:${NC}"
    echo "    GPG_KEY_ID   Optional specific GPG key ID to use (e.g., 92C79989BA17D56B)"
    echo "                 If not provided, will use the first available key"
    echo ""
    echo -e "${YELLOW}Example:${NC}"
    echo "    $0                       # Use first available GPG key"
    echo "    $0 92C79989BA17D56B     # Use specific GPG key"
    echo ""
    echo -e "${YELLOW}What this script does:${NC}"
    echo "    • Installs/updates GPG and pinentry-mac via Homebrew"
    echo "    • Configures GPG agent and directories with proper permissions"
    echo "    • Sets up Git for GPG signing"
    echo "    • Updates shell profile with GPG_TTY"
    echo "    • Tests the GPG signing configuration"
    echo "    • Exports public key for GitHub"
    echo ""
    echo -e "${YELLOW}Requirements:${NC}"
    echo "    • macOS (Intel or Apple Silicon)"
    echo "    • Homebrew package manager"
    echo "    • At least one GPG key (or GPG Keychain to create one)"
    echo ""
}

# Check for help flag
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    show_help
    exit 0
fi

print_header
log "Starting GPG Fix & Repair for macOS..." "$BLUE"

# 1. Check GPG installation
log "[1/10] Checking GPG installation..." "$YELLOW"
if ! command -v gpg &> /dev/null; then
    log "GPG not found! Installing via Homebrew..." "$RED"
    if ! command -v brew &> /dev/null; then
        log "Homebrew not found! Please install Homebrew first:" "$RED"
        log "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" "$YELLOW"
        exit 1
    fi
    brew install gnupg
else
    log "✓ GPG installed ($(gpg --version | head -n1))" "$GREEN"
fi

# 2. Check pinentry-mac installation
log "[2/10] Checking pinentry-mac..." "$YELLOW"
if ! command -v pinentry-mac &> /dev/null; then
    log "Pinentry-mac not found, installing..." "$YELLOW"
    brew install pinentry-mac
else
    log "✓ Pinentry-mac installed" "$GREEN"
fi

# 3. Create GPG directories and set permissions
log "[3/10] Setting GPG directory permissions..." "$YELLOW"
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
chmod 600 ~/.gnupg/* 2>/dev/null || true
log "✓ Directory permissions configured" "$GREEN"

# 4. Configure GPG agent
log "[4/10] Configuring GPG agent..." "$YELLOW"
cat > ~/.gnupg/gpg-agent.conf << EOF
# GPG Agent Configuration
default-cache-ttl 28800
max-cache-ttl 86400
pinentry-program /opt/homebrew/bin/pinentry-mac
enable-ssh-support
EOF

# Check for Intel Mac
if [ ! -f "/opt/homebrew/bin/pinentry-mac" ]; then
    if [ -f "/usr/local/bin/pinentry-mac" ]; then
        sed -i '' 's|/opt/homebrew/bin/pinentry-mac|/usr/local/bin/pinentry-mac|g' ~/.gnupg/gpg-agent.conf
    fi
fi
log "✓ GPG agent configuration complete" "$GREEN"

# 5. Configure GPG settings
log "[5/10] Configuring GPG..." "$YELLOW"
cat > ~/.gnupg/gpg.conf << EOF
# GPG Configuration
use-agent
no-tty
EOF
log "✓ GPG configuration complete" "$GREEN"

# 6. Restart GPG agent
log "[6/10] Restarting GPG agent..." "$YELLOW"
gpgconf --kill gpg-agent
gpg-agent --daemon 2>/dev/null
log "✓ GPG agent restarted" "$GREEN"

# 7. Check GPG keys
log "[7/10] Checking GPG keys..." "$YELLOW"
GPG_KEYS=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep "^sec" | awk -F'/' '{print $2}' | awk '{print $1}')

if [ -z "$GPG_KEYS" ]; then
    log "! No GPG keys found" "$RED"
    log "  Please create or import a key using GPG Keychain" "$YELLOW"
    log "" "$NC"
    log "To create a new key:" "$YELLOW"
    log "  gpg --full-generate-key" "$BLUE"
    log "" "$NC"
    log "Or use GPG Keychain app:" "$YELLOW"
    log "  1. Open GPG Keychain" "$NC"
    log "  2. Click 'New' to create a key" "$NC"
    log "  3. Run this script again" "$NC"
else
    log "✓ GPG keys found:" "$GREEN"
    for key in $GPG_KEYS; do
        key_info=$(gpg --list-keys --keyid-format=long "$key" 2>/dev/null | grep "uid" | head -n1)
        log "  → $key: ${key_info#*] }" "$BLUE"
    done

    # Use provided key or first available key
    if [ -z "$PRIMARY_KEY" ]; then
        PRIMARY_KEY=$(echo "$GPG_KEYS" | awk '{print $1}')
        log "Using first available key: $PRIMARY_KEY" "$YELLOW"
    else
        # Validate provided key exists
        if ! echo "$GPG_KEYS" | grep -q "$PRIMARY_KEY"; then
            log "Provided key $PRIMARY_KEY not found!" "$RED"
            log "Available keys: $GPG_KEYS" "$YELLOW"
            exit 1
        fi
        log "Using specified key: $PRIMARY_KEY" "$GREEN"
    fi

    # 8. Configure Git signing
    log "[8/10] Configuring Git signing..." "$YELLOW"

    # Get current Git user info
    GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
    GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

    if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
        log "Git user info missing, extracting from GPG key..." "$YELLOW"

        # Extract info from GPG key
        GPG_INFO=$(gpg --list-keys --keyid-format=long "$PRIMARY_KEY" 2>/dev/null | grep "uid")
        if [ -n "$GPG_INFO" ]; then
            # Extract email
            GPG_EMAIL=$(echo "$GPG_INFO" | grep -oE '<[^>]+>' | tr -d '<>')
            # Extract name
            GPG_NAME=$(echo "$GPG_INFO" | sed 's/.*\] //' | sed 's/ <.*//')

            if [ -n "$GPG_NAME" ] && [ -z "$GIT_NAME" ]; then
                git config --global user.name "$GPG_NAME"
                log "✓ Git username set: $GPG_NAME" "$GREEN"
            fi

            if [ -n "$GPG_EMAIL" ] && [ -z "$GIT_EMAIL" ]; then
                git config --global user.email "$GPG_EMAIL"
                log "✓ Git email set: $GPG_EMAIL" "$GREEN"
            fi
        fi
    else
        log "✓ Git user info already configured" "$GREEN"
    fi

    # Configure GPG signing
    git config --global user.signingkey "$PRIMARY_KEY"
    git config --global commit.gpgsign true
    git config --global gpg.program "$(which gpg)"

    log "✓ Git GPG signing configured" "$GREEN"
    log "  → Signing key: $PRIMARY_KEY" "$BLUE"
fi

# 9. Update shell profile
log "[9/10] Updating shell profile..." "$YELLOW"

# Detect current shell
CURRENT_SHELL="$SHELL"
if [[ "$CURRENT_SHELL" == *"zsh"* ]]; then
    PROFILE_FILE="$HOME/.zshrc"
elif [[ "$CURRENT_SHELL" == *"bash"* ]]; then
    PROFILE_FILE="$HOME/.bash_profile"
else
    PROFILE_FILE="$HOME/.profile"
fi

# Add GPG_TTY export if not exists
if ! grep -q "export GPG_TTY" "$PROFILE_FILE" 2>/dev/null; then
    echo -e "\n# GPG signing support" >> "$PROFILE_FILE"
    echo "export GPG_TTY=\$(tty)" >> "$PROFILE_FILE"
    log "✓ GPG_TTY export added to $PROFILE_FILE" "$GREEN"
else
    log "✓ GPG_TTY export already exists" "$GREEN"
fi

# 10. Test and verify
log "[10/10] Testing configuration..." "$YELLOW"

# Check if GPG agent is running
if gpg-agent 2>/dev/null; then
    log "✓ GPG agent is running" "$GREEN"
else
    log "! GPG agent is not running" "$RED"
fi

# Test signing
if [ -n "$PRIMARY_KEY" ]; then
    TEST_FILE="/tmp/gpg_test_$$.txt"
    echo "Test" > "$TEST_FILE"
    if gpg --armor --detach-sign --default-key "$PRIMARY_KEY" "$TEST_FILE" 2>/dev/null; then
        log "✓ GPG signing test successful" "$GREEN"
        rm -f "$TEST_FILE" "$TEST_FILE.asc"
    else
        log "! GPG signing test failed (password may be required)" "$YELLOW"
        rm -f "$TEST_FILE"
    fi
fi

# Summary
echo ""
log "=======================================" "$GREEN"
log "        Setup Complete!                " "$GREEN"
log "=======================================" "$GREEN"
echo ""

if [ -n "$PRIMARY_KEY" ]; then
    log "GitHub GPG Public Key:" "$BLUE"
    echo ""
    gpg --armor --export "$PRIMARY_KEY"
    echo ""
    log "NEXT STEPS:" "$YELLOW"
    log "1. Copy the GPG public key above" "$NC"
    log "2. Go to GitHub.com → Settings → SSH and GPG keys → New GPG key" "$NC"
    log "3. Paste the key and save" "$NC"
    log "4. Restart your terminal or run: source $PROFILE_FILE" "$BLUE"
    log "5. GPG password will be requested on first commit" "$NC"
    echo ""
else
    log "No GPG key available!" "$YELLOW"
    log "1. Open GPG Keychain app" "$NC"
    log "2. Create a new key or import existing key" "$NC"
    log "3. Run this script again" "$NC"
    echo ""
fi

log "Current Git GPG Configuration:" "$BLUE"
echo "user.name       : $(git config --global user.name)"
echo "user.email      : $(git config --global user.email)"
echo "user.signingkey : $(git config --global user.signingkey)"
echo "commit.gpgsign  : $(git config --global commit.gpgsign)"
echo "gpg.program     : $(git config --global gpg.program)"
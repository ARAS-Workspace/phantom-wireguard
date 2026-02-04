#!/usr/bin/env bash
# ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗
# ██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║
# ██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║
# ██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║
# ██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║
# ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝
# Copyright (c) 2025 Rıza Emre ARAS <r.emrearas@proton.me>
# =============================================================================
# Asciinema Record & GIF Conversion Script
# Records terminal sessions and converts them to GIF using agg (Docker)
# =============================================================================
#
# REQUIREMENTS:
#   - asciinema    : Terminal session recorder
#                    Install: sudo apt install asciinema (Debian/Ubuntu)
#                             sudo zypper install asciinema (openSUSE)
#                             pip install asciinema
#
#   - docker       : Container runtime for agg
#                    Install: https://docs.docker.com/engine/install/
#
#   - agg (Docker) : Asciinema GIF generator
#                    Build: docker build -t agg https://github.com/asciinema/agg.git
#
#   - Noto Emoji   : (Optional) For emoji support in GIF output
#                    Install: mkdir -p ~/.local/share/fonts
#                             wget -O ~/.local/share/fonts/NotoColorEmoji.ttf \
#                                  https://github.com/googlefonts/noto-emoji/raw/main/fonts/NotoColorEmoji.ttf
#
# USAGE:
#   ./record.sh <recording-name> [title]
#
# EXAMPLES:
#   ./record.sh install-demo
#   ./record.sh install-demo "Installation Demo"
#
# =============================================================================

set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────

# Asciinema settings
COLS=120
ROWS=48
IDLE_LIMIT=2

# agg settings
SPEED=1.5
FPS_CAP=12
THEME="monokai"
LAST_FRAME_DURATION=3

# Directories
CAST_DIR="./recordings"
GIF_DIR="./assets/recordings"

# ─────────────────────────────────────────────────────────────
# Functions
# ─────────────────────────────────────────────────────────────

usage() {
    cat <<EOF
Usage: ./record.sh <recording-name> [title]

Examples:
    ./record.sh install-demo
    ./record.sh install-demo "Installation Demo"

Outputs:
    ${CAST_DIR}/<recording-name>.cast
    ${GIF_DIR}/<recording-name>.gif
EOF
    exit 1
}

check_dependencies() {
    local missing=()

    command -v asciinema &>/dev/null || missing+=("asciinema")
    command -v docker &>/dev/null || missing+=("docker")

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Error: Missing dependencies: ${missing[*]}"
        exit 1
    fi
}

interactive_trim() {
    local cast_file="$1"

    clear
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "POST-PROCESS: Trim Recording"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "This step allows you to remove unwanted lines from the end"
    echo "of your recording (e.g., exit commands, typos)."
    echo ""
    echo "Last 25 lines of the recording:"
    echo "────────────────────────────────────────────────────────────"
    nl -ba "$cast_file" | tail -n 25
    echo "────────────────────────────────────────────────────────────"
    echo ""
    echo "Enter a line number to remove that line and everything below it."
    echo "Press Enter to skip (no trimming)."
    echo ""
    # shellcheck disable=SC2162
    read -p "Trim from line: " trim_line

    if [[ -n "$trim_line" ]]; then
        sed -i "${trim_line},\$d" "$cast_file"
        echo ""
        echo "✓ Trimmed: Removed line $trim_line and below"
    else
        echo ""
        echo "✓ Skipped: No trimming applied"
    fi

    sleep 1
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

main() {
    [[ $# -lt 1 ]] && usage

    local name="$1"
    local title="${2:-$name}"
    local cast_file="${CAST_DIR}/${name}.cast"
    local gif_file="${GIF_DIR}/${name}.gif"

    check_dependencies

    # Create directories
    mkdir -p "$CAST_DIR" "$GIF_DIR"

    # Set terminal size
    printf '\033[8;%d;%dt' "$ROWS" "$COLS"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Recording: $title"
    echo "Exit with: Ctrl+D or 'exit'"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    # Asciinema recording
    asciinema rec \
        --cols "$COLS" \
        --rows "$ROWS" \
        --idle-time-limit "$IDLE_LIMIT" \
        -t "$title" \
        "$cast_file"

    echo
    echo "Recording complete: $cast_file"
    echo

    # Ask for trim review
    # shellcheck disable=SC2162
    read -p "Review and trim last lines before GIF conversion? [y/N]: " trim_choice

    if [[ "$trim_choice" =~ ^[Yy]$ ]]; then
        interactive_trim "$cast_file"
    fi

    echo ""
    echo "Converting to GIF..."

    # GIF conversion with agg (Docker)
    docker run --rm \
        -v "$(pwd)":/data \
        -v "$HOME/.local/share/fonts":/fonts:ro \
        agg:latest \
        --font-dir /fonts \
        --speed "$SPEED" \
        --fps-cap "$FPS_CAP" \
        --theme "$THEME" \
        --last-frame-duration "$LAST_FRAME_DURATION" \
        "/data/${cast_file}" \
        "/data/${gif_file}"

    # Result
    local gif_size
    gif_size=$(du -h "$gif_file" | cut -f1)

    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✓ Complete!"
    echo "  Cast: $cast_file"
    echo "  GIF:  $gif_file ($gif_size)"
    echo
    echo "Markdown usage:"
    echo "  ![${name}](./${gif_file})"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main "$@"
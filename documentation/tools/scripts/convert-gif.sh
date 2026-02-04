#!/usr/bin/env bash
# ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗
# ██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║
# ██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║
# ██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║
# ██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║
# ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝
# Copyright (c) 2025 Rıza Emre ARAS <r.emrearas@proton.me>
# =============================================================================
# Batch .cast → .gif Converter (Dark & Light)
# Converts .cast files to GIF with solarized-dark and solarized-light themes
# =============================================================================
#
# REQUIREMENTS:
#   - docker : Container runtime for agg
#   - agg    : docker build -t agg https://github.com/asciinema/agg.git
#
# USAGE:
#   ./convert-gif.sh <input_dir> <output_dir>
#
# EXAMPLES:
#   ./convert-gif.sh ../recordings ../assets/recordings
#   ./convert-gif.sh /path/to/casts /path/to/gifs
#
# OUTPUT:
#   <output_dir>/<name>-dark.gif    (solarized-dark theme)
#   <output_dir>/<name>-light.gif   (solarized-light theme)
#
# =============================================================================

set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Configuration (synced with record.sh)
# ─────────────────────────────────────────────────────────────
SPEED=1.5
FPS_CAP=12
LAST_FRAME_DURATION=3

DARK_THEME="solarized-dark"
LIGHT_THEME="solarized-light"

# ─────────────────────────────────────────────────────────────
# Functions
# ─────────────────────────────────────────────────────────────

usage() {
    cat <<EOF
Usage: ./convert-gif.sh <input_dir> <output_dir>

Arguments:
    input_dir   Directory containing .cast files
    output_dir  Directory for generated .gif files (cleaned before each run)

Examples:
    ./convert-gif.sh ../recordings ../assets/recordings
    ./convert-gif.sh /path/to/casts /path/to/gifs
EOF
    exit 1
}

prepare_output_dir() {
    local dir="$1"

    if [[ -d "$dir" ]]; then
        echo "Cleaning output directory: ${dir}"
        rm -rf "$dir"
    fi

    mkdir -p "$dir"
    echo "Output directory ready: ${dir}"
    echo ""
}

convert() {
    local input_dir="$1"
    local output_dir="$2"
    local cast_file="$3"
    local output_file="$4"
    local theme="$5"

    docker run --rm \
        -v "${input_dir}":/cast:ro \
        -v "${output_dir}":/gif \
        -v "$HOME/.local/share/fonts":/fonts:ro \
        agg:latest \
        --font-dir /fonts \
        --speed "$SPEED" \
        --fps-cap "$FPS_CAP" \
        --theme "$theme" \
        --last-frame-duration "$LAST_FRAME_DURATION" \
        "/cast/${cast_file}" \
        "/gif/${output_file}"
}

process_cast() {
    local input_dir="$1"
    local output_dir="$2"
    local cast_file="$3"
    local name="${cast_file%.cast}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Converting: ${cast_file}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    convert "$input_dir" "$output_dir" "$cast_file" "${name}-dark.gif" "$DARK_THEME"
    local dark_size
    dark_size=$(du -h "${output_dir}/${name}-dark.gif" | cut -f1)
    echo "  [dark]  ${name}-dark.gif  (${dark_size})"

    convert "$input_dir" "$output_dir" "$cast_file" "${name}-light.gif" "$LIGHT_THEME"
    local light_size
    light_size=$(du -h "${output_dir}/${name}-light.gif" | cut -f1)
    echo "  [light] ${name}-light.gif (${light_size})"

    echo ""
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

main() {
    [[ $# -lt 2 ]] && usage

    local input_dir
    local output_dir
    input_dir="$(cd "$1" && pwd)"
    output_dir="$(mkdir -p "$2" && cd "$2" && pwd)"

    # Check docker
    if ! command -v docker &>/dev/null; then
        echo "Error: docker is required"
        exit 1
    fi

    # Validate input directory has .cast files
    if ! ls "${input_dir}"/*.cast &>/dev/null; then
        echo "Error: No .cast files found in ${input_dir}"
        exit 1
    fi

    echo "Input:  ${input_dir}"
    echo "Output: ${output_dir}"
    echo ""

    # Clean and prepare output directory
    prepare_output_dir "$output_dir"

    local count=0

    for cast_file in "${input_dir}"/*.cast; do
        [[ -f "$cast_file" ]] || continue
        local basename
        basename="$(basename "$cast_file")"
        process_cast "$input_dir" "$output_dir" "$basename"
        ((count++))
    done

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Complete: ${count} cast files → $((count * 2)) GIF files"
    echo "Output:   ${output_dir}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main "$@"
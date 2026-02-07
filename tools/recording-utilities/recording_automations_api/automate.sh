#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# automate.sh - API Recording Automation
# ═══════════════════════════════════════════════════════════════
# Records all API scripts in logical order.
# Output: ./recordings/api/<script>.cast
#
# Environment:
#   RECORD_LIMIT - Limit number of recordings (0 = unlimited)
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CAST_DIR="./recordings/api"
COLS=120
ROWS=48
IDLE_LIMIT=2
LIMIT="${RECORD_LIMIT:-0}"

# ─── Script Order (logical flow) ────────────────────────────────
SCRIPTS=(
    # Core Module
    "server_status"
    "add_client"
    "remove_client"
    "list_clients"
    "export_client"
    "latest_clients"
    "tweak_settings"
    "change_subnet"
    "get_firewall_status"
    "service_logs"
    "restart_service"
    # DNS Module
    "dns_compact"
)

mkdir -p "$CAST_DIR"

count=0
for name in "${SCRIPTS[@]}"; do
    # Check limit
    if [[ "$LIMIT" -gt 0 && "$count" -ge "$LIMIT" ]]; then
        echo "Limit reached ($LIMIT recordings). Stopping."
        break
    fi

    script="$SCRIPT_DIR/api/${name}.sh"

    if [[ ! -f "$script" ]]; then
        echo "Warning: $script not found, skipping"
        continue
    fi

    cast_file="${CAST_DIR}/${name}.cast"
    echo "Recording: $name"

    asciinema rec \
        --cols "$COLS" \
        --rows "$ROWS" \
        --idle-time-limit "$IDLE_LIMIT" \
        -t "$name" \
        -c "bash '$script'" \
        "$cast_file" || echo "Failed: $name"

    count=$((count + 1))
    sleep 1
done

echo "Done. Recorded $count files. Output: $CAST_DIR/"

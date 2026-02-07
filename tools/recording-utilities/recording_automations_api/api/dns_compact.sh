#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# dns_compact.sh - Phantom-WG DNS Management API Demo Recording
# ═══════════════════════════════════════════════════════════════
# Usage: Start ./record.sh first, then run this script
# Output: recordings/api/dns_compact
# ═══════════════════════════════════════════════════════════════

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# ═══════════════════════════════════════════════════════════════
# SCENARIO FLOW
# ═══════════════════════════════════════════════════════════════

# ─── Step 0: Initial setup ──────────────────────────────────
clear
sleep 0.5

# ─── Step 1: SSH into the server ────────────────────────────
ssh_connect

# ─── Step 2: Check current DNS status ───────────────────────
run_command 'phantom-api dns status' "$PAUSE_AFTER_EXEC_LONG"

do_clear

# ─── Step 3: Get current DNS servers ────────────────────────
run_command 'phantom-api dns get_dns_servers' "$PAUSE_AFTER_EXEC"

do_clear

# ─── Step 4: Change DNS servers to Cloudflare ───────────────
run_command 'phantom-api dns change_dns_servers primary="1.1.1.1" secondary="1.0.0.1"' "$PAUSE_AFTER_EXEC_LONG"

do_clear

# ─── Step 5: Test the new DNS configuration ─────────────────
run_command 'phantom-api dns test_dns_servers' "$PAUSE_AFTER_EXEC_LONG"

do_clear

# ─── Step 6: Verify final status ────────────────────────────
run_command 'phantom-api dns status' "$PAUSE_AFTER_EXEC_LONG"

# ─── End ────────────────────────────────────────────────────
sleep 1.0

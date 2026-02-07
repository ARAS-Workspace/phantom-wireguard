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
# Demonstrates DNS change effect on client configs
# ═══════════════════════════════════════════════════════════════

# ─── Step 0: Initial setup ──────────────────────────────────
clear
sleep 0.5

# ─── Step 1: SSH into the server ────────────────────────────
ssh_connect

# ─── Step 2: Check current DNS status ───────────────────────
run_command 'phantom-api dns status' "$PAUSE_AFTER_EXEC_LONG"

do_clear

# ─── Step 3: Show client config BEFORE DNS change ──────────
run_command "phantom-api core export_client client_name=\"bob-phone\" | jq -r '.data.config'" "$PAUSE_AFTER_EXEC_LONG"

do_clear

# ─── Step 4: Change DNS servers to Quad9 ────────────────────
run_command 'phantom-api dns change_dns_servers primary="9.9.9.9" secondary="149.112.112.112"' "$PAUSE_AFTER_EXEC_LONG"

do_clear

# ─── Step 5: Show client config AFTER DNS change ───────────
run_command "phantom-api core export_client client_name=\"bob-phone\" | jq -r '.data.config'" "$PAUSE_AFTER_EXEC_LONG"

do_clear

# ─── Step 6: Test the new DNS configuration ─────────────────
run_command 'phantom-api dns test_dns_servers' "$PAUSE_AFTER_EXEC_LONG"

do_clear

# ─── Step 7: Verify final status ────────────────────────────
run_command 'phantom-api dns status' "$PAUSE_AFTER_EXEC_LONG"

# ─── End ────────────────────────────────────────────────────
sleep 1.0

#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# export_client.sh - Phantom-WG export_client API Demo Recording
# ═══════════════════════════════════════════════════════════════
# Usage: Start ./record.sh first, then run this script
# Output: recordings/api/export_client
# ═══════════════════════════════════════════════════════════════

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# ═══════════════════════════════════════════════════════════════
# SCENARIO FLOW
# Uses "alice-laptop" created by list_clients.sh
# ═══════════════════════════════════════════════════════════════

# ─── Step 0: Initial setup ──────────────────────────────────
clear
sleep 0.5

# ─── Step 1: SSH into the server ────────────────────────────
ssh_connect

# ─── Step 2: Export client (full JSON response) ─────────────
run_command 'phantom-api core export_client client_name="alice-laptop"' "$PAUSE_AFTER_EXEC_LONG"

do_clear

# ─── Step 3: Export and extract config with jq ──────────────
run_command "phantom-api core export_client client_name=\"alice-laptop\" | jq -r '.data.config'" "$PAUSE_AFTER_EXEC_LONG"

do_clear

# ─── Step 4: Save config to file ────────────────────────────
run_command "phantom-api core export_client client_name=\"alice-laptop\" | jq -r '.data.config' > alice-laptop.conf" 1.5
run_command 'cat alice-laptop.conf' "$PAUSE_AFTER_EXEC_LONG"

# ─── End ────────────────────────────────────────────────────
sleep 1.0

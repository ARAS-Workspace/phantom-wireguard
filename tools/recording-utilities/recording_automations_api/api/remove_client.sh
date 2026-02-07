#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# remove_client.sh - Phantom-WG remove_client API Demo Recording
# ═══════════════════════════════════════════════════════════════
# Usage: Start ./record.sh first, then run this script
# Output: recordings/api/remove_client
# ═══════════════════════════════════════════════════════════════

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# ═══════════════════════════════════════════════════════════════
# SCENARIO FLOW
# Removes "demo-client" created by add_client.sh
# ═══════════════════════════════════════════════════════════════

# ─── Step 0: Initial setup ──────────────────────────────────
clear
sleep 0.5

# ─── Step 1: SSH into the server ────────────────────────────
ssh_connect

# ─── Step 2: Show clients before removal ────────────────────
run_command 'phantom-api core list_clients search="demo-client"' "$PAUSE_AFTER_EXEC"

do_clear

# ─── Step 3: Remove the client ──────────────────────────────
run_command 'phantom-api core remove_client client_name="demo-client"' "$PAUSE_AFTER_EXEC_LONG"

do_clear

# ─── Step 4: Verify removal ─────────────────────────────────
run_command 'phantom-api core list_clients search="demo-client"' "$PAUSE_AFTER_EXEC_LONG"

# ─── End ────────────────────────────────────────────────────
sleep 1.0

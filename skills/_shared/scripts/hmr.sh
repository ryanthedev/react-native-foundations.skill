#!/usr/bin/env bash
set -euo pipefail

# hmr.sh -- HMR WebSocket event monitor
# Commands: monitor

# Resolve Metro port: --port flag > RCT_METRO_PORT env > 8081
resolve_port() {
    if [[ -z "${PORT:-}" ]]; then
        PORT="${RCT_METRO_PORT:-8081}"
    fi
}

usage() {
    echo "Usage: hmr.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  monitor          Stream HMR update events as NDJSON"
    echo ""
    echo "Options:"
    echo "  --port <PORT>    Metro port (default: \$RCT_METRO_PORT or 8081)"
    echo "  --timeout <SEC>  Stop after SEC seconds (default: unlimited)"
    exit 1
}

cmd_monitor() {
    local TIMEOUT=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --timeout) TIMEOUT="$2"; shift 2 ;;
            *) echo "Error: Unknown option '$1'" >&2; exit 1 ;;
        esac
    done

    resolve_port

    # Check Metro is running (same pattern as metro.sh require_metro_running)
    local response
    if ! response=$(curl -s --connect-timeout 2 --max-time 5 "http://localhost:${PORT}/status" 2>/dev/null); then
        echo "Error: Metro is not running on port ${PORT}" >&2
        exit 1
    fi
    if [[ "$response" != *"packager-status:running"* ]]; then
        echo "Error: Metro is not running on port ${PORT}" >&2
        exit 1
    fi

    # Check Node 22+ is available (native WebSocket required)
    local node_major
    node_major=$(node --version 2>/dev/null | sed 's/^v//' | cut -d. -f1)
    if [[ -z "$node_major" || "$node_major" -lt 22 ]]; then
        echo "Error: hmr.sh requires Node 22+, found $(node --version 2>/dev/null || echo 'none')" >&2
        exit 1
    fi

    # Run inline Node script to connect to HMR WebSocket and stream NDJSON
    node - "$PORT" "$TIMEOUT" <<'NODESCRIPT'
"use strict";

const port = process.argv[2];
const timeoutSec = process.argv[3] ? parseInt(process.argv[3], 10) : 0;

const ws = new WebSocket(`ws://localhost:${port}/hot`);

ws.addEventListener("open", () => {
    // Register as an entrypoint client to receive HMR updates
    ws.send(JSON.stringify({
        type: "register-entrypoints",
        entryPoints: ["index"]
    }));
});

ws.addEventListener("message", (event) => {
    let msg;
    try {
        msg = JSON.parse(event.data);
    } catch {
        return;
    }

    const type = msg.type;
    if (!type) return;

    const timestamp = Date.now();

    if (type === "update-start") {
        process.stdout.write(JSON.stringify({ type, timestamp }) + "\n");
    } else if (type === "update") {
        // Extract module name from body.name or body.modified array
        const body = msg.body || {};
        const module = body.name || (Array.isArray(body.modified) ? body.modified : []);
        process.stdout.write(JSON.stringify({ type, module, timestamp }) + "\n");
    } else if (type === "update-done") {
        process.stdout.write(JSON.stringify({ type, timestamp }) + "\n");
    } else if (type === "error") {
        const body = msg.body || {};
        const errors = body.errors || [];
        process.stdout.write(JSON.stringify({ type, errors, timestamp }) + "\n");
    }
    // Unknown message types are silently skipped
});

ws.addEventListener("error", (err) => {
    process.stderr.write(`Error: WebSocket connection failed on port ${port}\n`);
    process.exit(1);
});

ws.addEventListener("close", () => {
    process.exit(0);
});

// Timeout: close WebSocket after specified duration
if (timeoutSec > 0) {
    setTimeout(() => {
        ws.close();
    }, timeoutSec * 1000);
}

// Signal handling: close WebSocket gracefully
process.on("SIGINT", () => { ws.close(); });
process.on("SIGTERM", () => { ws.close(); });
NODESCRIPT
}

# --- Main ---

if [[ $# -lt 1 ]]; then
    usage
fi

# Extract --port from anywhere in args before dispatching
ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --port) PORT="$2"; shift 2 ;;
        *)      ARGS+=("$1"); shift ;;
    esac
done

if [[ ${#ARGS[@]} -lt 1 ]]; then
    usage
fi

command="${ARGS[0]}"
# Remove the command from ARGS, pass remainder to subcommand
REMAINING_ARGS=("${ARGS[@]:1}")

case "$command" in
    monitor) cmd_monitor "${REMAINING_ARGS[@]+"${REMAINING_ARGS[@]}"}" ;;
    *)       echo "Error: Unknown command '$command'" >&2; usage ;;
esac

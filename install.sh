#!/usr/bin/env bash
# Install claude-grok launcher onto PATH.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST_DIR="${DEST_DIR:-$HOME/bin}"
DEST="$DEST_DIR/claude-grok"

mkdir -p "$DEST_DIR"
install -m 755 "$ROOT/bin/claude-grok" "$DEST"
install -m 755 "$ROOT/bin/claude-grok-bridge" "$DEST_DIR/claude-grok-bridge"

cat <<EOF
Installed:
  $DEST
  $DEST_DIR/claude-grok-bridge

Prereqs (once):
  1. Claude Code CLI: https://docs.anthropic.com/en/docs/claude-code
  2. brew install raine/claude-code-proxy/claude-code-proxy
  3. claude-code-proxy grok auth login
  4. Optional Codex for /model switching:
       claude-code-proxy codex auth login
       # or keep Codex CLI logged in (~/.codex/auth.json is imported on launch)
  5. Prefer patched proxy + LaunchAgent — see docs/PATCHED-PROXY.md

Then run:
  claude-grok
  claude-grok models
  claude-grok auth

Inside Claude Code:
  /model                  # Grok custom row + Codex claude-* aliases
  /model gpt-5.6-sol      # Codex by typed id
EOF

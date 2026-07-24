#!/usr/bin/env bash
# Install claude-grok launcher onto PATH.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST_DIR="${DEST_DIR:-$HOME/bin}"
DEST="$DEST_DIR/claude-grok"

mkdir -p "$DEST_DIR"
install -m 755 "$ROOT/bin/claude-grok" "$DEST"

cat <<EOF
Installed: $DEST

Prereqs (once):
  1. Claude Code CLI: https://docs.anthropic.com/en/docs/claude-code
  2. brew install raine/claude-code-proxy/claude-code-proxy
  3. claude-code-proxy grok auth login
  4. brew services start raine/claude-code-proxy/claude-code-proxy

Then run:
  claude-grok
EOF

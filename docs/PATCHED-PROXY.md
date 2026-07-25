# Patched claude-code-proxy (Grok image tool_results)

Stock Homebrew `claude-code-proxy` **0.1.25** hard-fails Claude Code
`Read(png/jpg/...)` on the Grok provider:

```text
API Error: 400 tool result supports text children only
```

Upstream fix (still open): https://github.com/raine/claude-code-proxy/pull/69

## What we run locally

This machine runs a **rebased build**: `v0.1.25` + PR #69 commits, installed at:

```text
~/.local/bin/claude-code-proxy
```

LaunchAgent (replaces `brew services` for this binary):

```text
~/Library/LaunchAgents/com.devgwardo.claude-code-proxy.plist
```

Env on the service:

| Var | Value | Meaning |
|-----|-------|---------|
| `CCP_GROK_TOOL_IMAGE` | `reattach` | Send tool-result images to Grok as vision input (L2). Use `omit` to only placeholder, `reject` for old 400 behavior. |
| `XDG_STATE_HOME` | `~/.local/state` | Proxy logs / error captures |

## Rebuild / update

```bash
# from a checkout of raine/claude-code-proxy @ v0.1.25 with PR #69 cherry-picked
cargo build --release
cp target/release/claude-code-proxy ~/.local/bin/claude-code-proxy
codesign --force --deep --sign - ~/.local/bin/claude-code-proxy
launchctl kickstart -k gui/$(id -u)/com.devgwardo.claude-code-proxy
```

Verify (must NOT return the old 400):

```bash
# any Read(png)-shaped tool_result request against :18765
# expect upstream 200 or Grok auth/quota errors — never "text children only"
```

## Fallback

If you must use stock Homebrew proxy, set:

```bash
export CLAUDE_GROK_DISABLE_BRIDGE=0
```

so `claude-grok` routes through `claude-grok-bridge` (text placeholders only).

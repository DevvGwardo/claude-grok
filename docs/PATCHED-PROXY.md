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
| `CCP_GROK_CLIENT_VERSION` | `0.2.112` | Match current Grok CLI client version header. |
| `CCP_CURSOR_TRANSPORT` | `acp` | Cursor models via `cursor-agent acp` (same path as T3 Chat). Uses the real Claude Code cwd, agent mode + tool_use XML for Claude Code tools. Harness forbids Cursor-native Skill/AskUserQuestion and requires XML for every Claude Code tool. Use `cli` for `-p` rollback, `api` to debug Connect AgentService/Run. |
| `CCP_CURSOR_ACP_CWD` | (from Claude Code env) | Override ACP session cwd if needed. |
| `CCP_CURSOR_ACP_FORWARD_THOUGHTS` | off | Set `1` to stream Cursor thought chunks into Claude Code thinking UI. |
| `CCP_CURSOR_CLIENT_VERSION` | `cli-2026.07.23-e383d2b` | Cursor client version header when using `api` transport. |
| `XDG_STATE_HOME` | `~/.local/state` | Proxy logs / error captures |

Local patch on top of PR #69: Grok 402/4xx responses forward the **upstream body message** (e.g. `Grok Build usage balance exhausted`) instead of the opaque `Grok upstream rejected the request`.

## Quota / auth gotchas

- Proxy auth is `~/.config/claude-code-proxy/grok/auth.json` — **not** auto-synced from `~/.grok/auth.json`. Wrong account → 402 while `grok` CLI still works.
- When the OAuth account is correct and you still see 402, the real cause is usually **Grok Build usage balance exhausted** on that subscription (rolling window / plan limit). No proxy setting fixes that — wait for reset, buy credits, upgrade, or `/model` over to a Codex id.
- Cursor: proxy does not read IDE tokens by itself. `claude-grok` imports keychain `cursor-*-token` into `~/.config/claude-code-proxy/cursor/auth.json` on launch. **Do not use `cursor:grok-4.5` as your daily Claude Code model** — ACP wraps Cursor’s agent harness (same wire as T3), so tools/latency fight Claude Code. Prefer Codex `claude-sonnet-4-6` / `claude-opus-4-7`. Use Cursor Grok in the Cursor IDE or T3 Code instead.

## `/model` multi-provider

`claude-grok` sets:

- `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` — load proxy `/v1/models` into the picker
- `ANTHROPIC_CUSTOM_MODEL_OPTION=cursor:grok-4.5` — Cursor Grok picker row (discovery filters out non-`claude*` ids; type `grok-4.5` for grok.com Build)
- `CCP_ALIAS_PROVIDER=codex` — `opus` / `sonnet` / `haiku` → Codex
- Default small/opus/sonnet/haiku env vars → Codex ids (saves Grok Build quota)

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

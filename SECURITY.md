# Security Policy

## Scope

`claude-grok` is a local launcher. It does not store provider credentials itself.
Grok OAuth tokens are managed by `claude-code-proxy`.

## Reporting

Open a GitHub issue for non-sensitive bugs. For credential/account issues, rotate
tokens via:

```bash
claude-code-proxy grok auth login
```

Do not paste access tokens into issues.

---
description: Local-first and no-app-code guardrails
applyTo: "**"
---

# Local-first guardrails

This harness is a workflow scaffold, not an application scaffold.

Do not create any of the following unless the local SDD docs explicitly request them:

- business/domain application code
- framework scaffolding
- database schema or migrations
- GitHub remotes, commits, issues, pull requests, or CI configuration
- deployment files or cloud resources
- MCP servers or network service dependencies

Default to local Markdown files, explicit user approval for destructive actions, and reversible changes.

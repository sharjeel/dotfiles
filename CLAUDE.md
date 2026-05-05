@AGENTS.md
@ai/common/agent-baseline.md

## Claude Code Notes

- Skills live under `ai/skills/` as flat `.md` files; `install.sh` symlinks them into `~/.claude/skills/<name>/SKILL.md` (and the codex equivalent) at install time. Add or edit skills in `ai/skills/` only.
- For Coolify work on the personal server, use the `coolify-deploy` skill and keep the CLI context on `sai` unless the user explicitly overrides it.
- For installer or provisioning changes, use the `dotfiles-smoke-check` skill before finishing.

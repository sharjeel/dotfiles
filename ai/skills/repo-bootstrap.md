# Skill: Repo AI Bootstrap

Use this playbook when setting up a new repository to follow the same shared-agent layout used here.

## Standard Layout

- `AGENTS.md` for shared cross-agent instructions
- `CLAUDE.md` as a thin wrapper around `AGENTS.md`
- `GEMINI.md` for Gemini-specific notes
- `.gemini/settings.json` so Gemini loads `AGENTS.md` and `GEMINI.md`

## Command

- Run `~/.personalconfig/bin/ai-init <target-repo>`

## Follow-up

- Review the generated files instead of assuming they fit the new repository unchanged.
- Add repository-specific verification commands and architectural notes to the generated `AGENTS.md`.

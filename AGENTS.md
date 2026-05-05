# Agent Guide: .personalconfig

This repository contains global dotfiles and configuration scripts. Agents should follow these guidelines when working with this codebase.

## Core Principles

- **Reference, don't override:** The installation scripts (like `install.sh`) are designed to append or prepend `source` lines to existing system dotfiles (e.g., `~/.zshrc`, `~/.emacs.d/init.el`) rather than overwriting them entirely. This preserves existing machine-specific configurations.
- **Dry-run safety:** All major installation scripts (`install.sh`, `install-optional.sh`, `install-enhanced.sh`) support a `--dry-run` flag. Agents should use this to verify actions before execution.
- **Portability:** Configurations are intended to be cross-platform (Linux/macOS/FreeBSD), though some parts are Linux-specific.

## Key Files & Directories

- `install.sh`: The core installation script. It handles `zsh`, `emacs`, `bashmarks`, `tmux`, and `ack`.
- `zshrc.custom.zsh`: The primary shell configuration file. It includes custom bindings, history settings, and integrations for tools like `aichat` and `gcloud`.
- `zshaliases.custom.zsh`: Shared aliases used across different shell environments.
- `emacs.init.el`: Global Emacs configuration.
- `bin/`: Custom scripts and utilities.
- `test/`: Contains `container-smoke.sh` and `Dockerfile.smoke` for testing the configuration in a clean environment.

## Workflow for Agents

### 1. Research & Analysis
- Before suggesting changes to shell configurations, check `zshrc.custom.zsh` for existing bindings and aliases.
- Review `install.sh` to understand how a specific tool's configuration is integrated into the home directory.

### 2. Implementation
- When adding new dotfiles, add them to the root or an appropriate subdirectory and update `install.sh` to link or source them.
- Follow the `replace_or_append` / `replace_or_prepend` pattern in `install.sh` for non-destructive updates.

### 3. Verification & Testing
- **Mandatory:** Use `./test/container-smoke.sh test` to verify that installation scripts run correctly in a clean container.
- Use `./test/container-smoke.sh test-optional` when changes affect `install-optional.sh`, Prezto, zsh add-ons, or optional shell startup behavior.
- For interactive verification, use `./test/container-smoke.sh shell` for core setup and `./test/container-smoke.sh shell-optional` for Prezto/zsh optional setup.
- Always verify with `--dry-run` if modifying installation scripts directly.

## AI Shared Setup

- `AGENTS.md` is the canonical shared instruction file for this repository. Keep common guidance here so Codex and Gemini can consume the same project context.
- `CLAUDE.md` should stay thin and primarily import `AGENTS.md` plus any Claude-specific notes.
- `GEMINI.md` should stay thin; `ai/gemini-settings.json` is symlinked to `~/.gemini/settings.json` by `install.sh` so Gemini loads `AGENTS.md` and `GEMINI.md` together.
- Do not symlink `CLAUDE.md` or `GEMINI.md` to `AGENTS.md`; keep them as small wrappers so vendor-specific notes can diverge without duplicating the shared file.
- All agent playbooks live under `ai/skills/` as flat `.md` files. Do not add per-vendor skill folders (e.g. `.claude/skills/`); `install.sh` is responsible for symlinking the shared files into each vendor's global skills directory.
- For deployments to the personal Coolify server, default to the Coolify CLI context name `sai` unless the user explicitly asks for another context.
- When scaffolding AI files into another repository, prefer `bin/ai-init` over hand-copying files so the layout stays consistent.

## Custom Tooling
- `g`: A smart alias in `zshrc.custom.zsh` that resolves to either a `bashmark` (directory shortcut) or `git`.
- `explain`: Integration with `explainshell.com`.
- `aiselect`: A helper to switch `aichat` models using `fzf` and `yq`.

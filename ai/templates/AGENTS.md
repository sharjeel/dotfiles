# Agent Guide

This repository uses `AGENTS.md` as the shared source of truth for coding agents.

## Baseline Rules

- Keep common project instructions here so multiple agents can reuse the same guidance.
- Keep vendor-specific files such as `CLAUDE.md` and `GEMINI.md` thin.
- Do not symlink vendor files to `AGENTS.md`; keep them as small wrappers for vendor-specific notes.
- Prefer repository scripts, tests, and documented workflows over ad hoc commands.
- Validate changes with the repository’s normal verification commands before finishing.

## Fill In

- Project structure and key directories
- Preferred build, test, and lint commands
- Safety constraints
- Deployment workflow

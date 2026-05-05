# Shared Agent Baseline

- Keep shared project guidance in `AGENTS.md`. Vendor-specific files should stay small and point back to the shared instructions.
- Prefer repository-local playbooks and scripts over retyping procedures in prompts.
- For shell and installer changes in this dotfiles repo, preserve the existing non-destructive style:
  - append or prepend references instead of overwriting user-owned files
  - reuse the `replace_or_append` / `replace_or_prepend` pattern when touching installers
  - avoid assuming a clean git worktree
- When a change affects provisioning or shell startup behavior, verify locally with the repo’s documented checks before finishing.

# Skill: Dotfiles Smoke Check

Use this playbook after changing shell startup files, installers, or setup documentation in this repository.

## Verification Order

1. If `install.sh`, `install-optional.sh`, or `install-enhanced.sh` changed, run the relevant installer in `--dry-run` mode first.
2. Run the container smoke test:
   - `./test/container-smoke.sh test`
3. If shell files changed, also syntax-check the touched shell scripts when practical:
   - `zsh -n zshrc.custom.zsh zshaliases.custom.zsh ai.zsh`
   - `bash -n install.sh install-optional.sh install-enhanced.sh bin/ai-init`

## Reporting

- Call out any skipped checks.
- If the smoke test fails, fix the issue before finishing when feasible.

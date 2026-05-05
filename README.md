### Overview

This is a collection of my global dotfiles which remain same across my different machines. Rather than overriding the existing dotfiles files in the machine, it creates references in the existing dotfiles to these global files.

### Requirements

* `git` (only needed for fresh-machine bootstrap)

### Installation

Clone the repo and run the installer:

      git clone https://github.com/sharjeel/dotfiles.git ~/.personalconfig
      cd ~/.personalconfig
      ./install.sh

For full setup (core + optional tools) in one command:

      ./install-enhanced.sh

Or use one-step bootstrap on a fresh machine:

      bash -c "$(curl -fsSL https://raw.githubusercontent.com/sharjeel/dotfiles/master/bootstrap.sh)"

Optional dry run:

      ./install.sh --dry-run

For Windows, use `install.py` (currently emacs-focused).

### Optional Tools

Install optional utilities and shell add-ons (cross-platform best-effort: Linux/macOS/FreeBSD):

      ./install-optional.sh

This also enables Prezto `autosuggestions` in `~/.zpreztorc` during setup.

Useful flags:

      ./install-optional.sh --dry-run
      ./install-optional.sh --skip-chsh
      ./install-optional.sh --skip-python
      ./install-optional.sh --only-zsh

`install-enhanced.sh` forwards the same flags to `install-optional.sh` and also honors `--dry-run` for `install.sh`.

### AI Agent Setup

This repo now carries a shared multi-agent layout:

- `AGENTS.md`: canonical shared instructions for Codex, Gemini, and other agents
- `CLAUDE.md`: thin Claude wrapper that imports `AGENTS.md`
- `GEMINI.md`: Gemini-specific wrapper (paired with `ai/gemini-settings.json`, symlinked globally by `install.sh`)
- `ai/skills/`: shared playbooks — `install.sh` symlinks each into `~/.claude/skills/` and `~/.codex/skills/`
- `bin/ai-init`: bootstrap the same layout into another repository
- `ai.zsh`: shell helpers loaded from `zshrc.custom.zsh`

Useful commands:

      aiinit ~/src/new-repo
      aictx
      airun
      coolapps
      cooldeploy my-app

The Coolify deployment helpers and skills default to the personal Coolify CLI context `sai`.

### Testing

Run automated smoke checks in a clean Podman container:

      ./test/container-smoke.sh test

Run smoke checks that include zsh optional add-ons such as Prezto:

      ./test/container-smoke.sh test-optional

Open an interactive shell in the same clean environment (repo mounted at `~/.personalconfig`) for rapid manual testing:

      ./test/container-smoke.sh shell

Open an interactive shell after installing zsh optional add-ons such as Prezto:

      ./test/container-smoke.sh shell-optional

The smoke container runs as the non-root user `sharjeeltest` with hostname `dotfiles-smoke`, so the prompt and startup banner make it clear that you are inside the test instance.

Rebuild only the base test image:

      ./test/container-smoke.sh build

For faster repeated `apt-get update` in shell mode, the script persists apt metadata/cache in Podman volumes:
`dotfiles-apt-lists` and `dotfiles-apt-cache` (override via `APT_LISTS_VOLUME` / `APT_CACHE_VOLUME`).

The smoke image also pre-installs common Ubuntu optional packages (best-effort), so running the full `install-optional.sh` in shell mode is usually much faster.

The test image already includes `zsh` for faster iteration, and `install.sh` still installs `zsh` if missing on real machines (runs `apt-get update` before `apt-get install zsh` on Debian/Ubuntu). This may require `sudo` on non-root hosts.

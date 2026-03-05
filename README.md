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

### Testing

Run automated smoke checks in a clean Podman container:

      ./test/container-smoke.sh test

Open an interactive shell in the same clean environment (repo mounted at `~/.personalconfig`) for rapid manual testing:

      ./test/container-smoke.sh shell

Rebuild only the base test image:

      ./test/container-smoke.sh build

For faster repeated `apt-get update` in shell mode, the script persists apt metadata/cache in Podman volumes:
`dotfiles-apt-lists` and `dotfiles-apt-cache` (override via `APT_LISTS_VOLUME` / `APT_CACHE_VOLUME`).

The smoke image also pre-installs common Ubuntu optional packages (best-effort), so rerunning `install-optional.sh` in shell mode is usually much faster.

The test image already includes `zsh` for faster iteration, and `install.sh` still installs `zsh` if missing on real machines (runs `apt-get update` before `apt-get install zsh` on Debian/Ubuntu). This may require `sudo` on non-root hosts.

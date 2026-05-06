#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
SKIP_CHSH=0
SKIP_PYTHON=0
ONLY_ZSH=0
HOME_DIR="${HOME:?HOME is required}"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --skip-chsh) SKIP_CHSH=1 ;;
    --skip-python) SKIP_PYTHON=1 ;;
    --only-zsh) ONLY_ZSH=1 ;;
    -h|--help)
      cat <<'EOF'
Usage: ./install-optional.sh [options]

Options:
  --dry-run      Print commands without executing them
  --skip-chsh    Do not change the default shell to zsh
  --skip-python  Skip pip package installation
  --only-zsh     Run only zsh/prezto-related setup
EOF
      exit 0
      ;;
    *)
      echo "unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

log() {
  printf '[optional] %s\n' "$*"
}

warn() {
  printf '[optional][warn] %s\n' "$*" >&2
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] %q' "$1"
    shift
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
  else
    "$@"
  fi
}

run_as_root() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    run_cmd "$@"
  elif command -v sudo >/dev/null 2>&1; then
    run_cmd sudo "$@"
  else
    warn "need root privileges for: $*"
    return 1
  fi
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || run_cmd mkdir -p "$dir"
}

git_clone_or_update() {
  local repo="$1"
  local dest="$2"
  if [[ -d "$dest/.git" ]]; then
    log "updating $(basename "$dest")"
    run_cmd git -C "$dest" pull --ff-only || warn "failed to update $dest"
  elif [[ -e "$dest" ]]; then
    warn "$dest exists but is not a git checkout; skipping"
  else
    log "cloning $repo -> $dest"
    run_cmd git clone "$repo" "$dest"
  fi
}

install_apt_packages() {
  local packages=("$@")
  run_as_root apt-get update
  for pkg in "${packages[@]}"; do
    run_as_root apt-get install -y "$pkg" || warn "failed to install apt package: $pkg"
  done
}

install_brew_packages() {
  local packages=("$@")
  for pkg in "${packages[@]}"; do
    run_cmd brew install "$pkg" || warn "failed to install brew package: $pkg"
  done
}

install_pkg_packages() {
  local packages=("$@")
  for pkg in "${packages[@]}"; do
    run_as_root pkg install -y "$pkg" || warn "failed to install FreeBSD package: $pkg"
  done
}

install_python_packages() {
  if [[ "$SKIP_PYTHON" -eq 1 ]]; then
    log "skipping python package installation"
    return
  fi

  local pip_cmd=""
  if command_exists python3; then
    pip_cmd="python3 -m pip"
  elif command_exists pip3; then
    pip_cmd="pip3"
  elif command_exists pip; then
    pip_cmd="pip"
  fi

  if [[ -z "$pip_cmd" ]]; then
    warn "pip not found; skipping python packages"
    return
  fi

  local pip_extra_args=""
  if [[ -z "${VIRTUAL_ENV:-}" ]] && ls /usr/lib/python*/EXTERNALLY-MANAGED >/dev/null 2>&1; then
    pip_extra_args="--break-system-packages"
    log "detected externally-managed Python; using --break-system-packages"
  fi

  local common_pkgs=(requests httpie pyzmq zmq jsonschema tornado virtualenv virtualenvwrapper)
  for pkg in "${common_pkgs[@]}"; do
    run_cmd sh -c "$pip_cmd install --upgrade $pip_extra_args \"$pkg\"" || warn "failed to install pip package: $pkg"
  done

  run_cmd sh -c "$pip_cmd install $pip_extra_args 'ipython==5.4'" || warn "failed to install ipython==5.4"
}

install_bashmarks() {
  ensure_dir "$HOME_DIR/tmp"
  git_clone_or_update "https://github.com/sharjeel/bashmarks.git" "$HOME_DIR/tmp/bashmarks"
  if [[ -d "$HOME_DIR/tmp/bashmarks" ]]; then
    log "installing bashmarks"
    run_cmd sh -c "cd \"$HOME_DIR/tmp/bashmarks\" && make install" || warn "bashmarks install failed"
  fi
}

set_default_shell_to_zsh() {
  [[ "$SKIP_CHSH" -eq 1 ]] && { log "skipping chsh"; return; }

  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    warn "zsh not found; cannot change default shell"
    return
  fi

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    log "default shell already set to $zsh_path"
    return
  fi

  if ! command_exists chsh; then
    warn "chsh not available; skipping default shell update"
    return
  fi

  local current_user
  current_user="${USER:-$(id -un 2>/dev/null || true)}"
  if [[ -z "$current_user" ]]; then
    warn "unable to determine current username; skipping default shell update"
    return
  fi

  log "setting default shell to $zsh_path"
  run_cmd chsh -s "$zsh_path" "$current_user" || run_as_root chsh -s "$zsh_path" "$current_user" || warn "failed to run chsh"
}

install_os_packages() {
  local os
  os="$(uname -s)"

  case "$os" in
    Linux)
      if command_exists apt-get; then
        install_apt_packages \
          git zsh git-core emacs python3-pip python3-dev ack-grep build-essential tmux guake colordiff clipit htop \
          libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev
      elif command_exists dnf; then
        for pkg in git zsh emacs python3-pip python3-devel ack tmux guake colordiff htop libffi-devel openssl-devel libxml2-devel libxslt-devel libjpeg-turbo-devel zlib-devel; do
          run_as_root dnf install -y "$pkg" || warn "failed to install dnf package: $pkg"
        done
      elif command_exists yum; then
        for pkg in git zsh emacs python3-pip python3-devel ack tmux guake colordiff htop libffi-devel openssl-devel libxml2-devel libxslt-devel libjpeg-turbo-devel zlib-devel; do
          run_as_root yum install -y "$pkg" || warn "failed to install yum package: $pkg"
        done
      elif command_exists pacman; then
        run_as_root pacman -Sy --noconfirm
        for pkg in git zsh emacs python-pip ack tmux guake colordiff htop libffi openssl libxml2 libxslt libjpeg-turbo zlib; do
          run_as_root pacman -S --noconfirm "$pkg" || warn "failed to install pacman package: $pkg"
        done
      elif command_exists apk; then
        for pkg in git zsh emacs py3-pip ack tmux guake colordiff htop libffi-dev openssl-dev libxml2-dev libxslt-dev jpeg-dev zlib-dev; do
          run_as_root apk add --no-cache "$pkg" || warn "failed to install apk package: $pkg"
        done
      else
        warn "unsupported Linux package manager; skipping OS packages"
      fi
      ;;
    Darwin)
      if command_exists brew; then
        install_brew_packages emacs ack tmux zsh
      else
        warn "homebrew not found; skipping macOS packages"
      fi
      ;;
    FreeBSD)
      if command_exists pkg; then
        install_pkg_packages git zsh emacs py311-pip ack tmux guake yakuake colordiff clipit
      else
        warn "pkg not found; skipping FreeBSD packages"
      fi
      ;;
    *)
      warn "unsupported OS: $os"
      ;;
  esac
}

install_zsh_addons() {
  git_clone_or_update "https://github.com/sorin-ionescu/prezto.git" "$HOME_DIR/.zprezto"
  if [[ -d "$HOME_DIR/.zprezto/.git" ]]; then
    run_cmd git -C "$HOME_DIR/.zprezto" submodule sync --recursive || warn "failed to sync prezto submodules"
    run_cmd git -C "$HOME_DIR/.zprezto" submodule update --init --recursive || warn "failed to init/update prezto submodules"
  fi
  git_clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME_DIR/.zsh-syntax-highlighting"
  git_clone_or_update "https://github.com/zsh-users/zsh-autosuggestions.git" "$HOME_DIR/.zsh-autosuggestions"
}

configure_prezto() {
  local prezto_dir="$HOME_DIR/.zprezto"
  local zpreztorc="$HOME_DIR/.zpreztorc"
  [[ -d "$prezto_dir/runcoms" ]] || return

  for rcfile in "$prezto_dir"/runcoms/z*; do
    local dest="$HOME_DIR/.${rcfile##*/}"
    if [[ ! -e "$dest" ]]; then
      run_cmd ln -s "$rcfile" "$dest"
    fi
  done

  # Keep existing zpreztorc untouched. Only initialize it if missing.
  if [[ ! -e "$zpreztorc" ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] copy $prezto_dir/runcoms/zpreztorc -> $zpreztorc"
    else
      cp "$prezto_dir/runcoms/zpreztorc" "$zpreztorc"
    fi
  else
    log "keeping existing $zpreztorc as-is"
  fi
}

set_prezto_theme_ansible_style() {
  local file="$HOME_DIR/.zpreztorc"
  local line="zstyle ':prezto:module:prompt' theme 'sharjeel'"
  local regex='^zstyle.*theme.*$'

  # Match Ansible lineinfile(create=no): do nothing if file is missing.
  [[ -f "$file" ]] || return

  if grep -Eq "$regex" "$file"; then
    run_cmd sed -E -i "s|$regex|$line|" "$file"
  elif [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] append prezto theme line to $file: $line"
  else
    printf '%s\n' "$line" >>"$file"
  fi
}

ensure_prezto_module() {
  local module="$1"
  local file="$HOME_DIR/.zpreztorc"
  [[ -f "$file" ]] || return

  if grep -Eq "['\"]${module}['\"]" "$file"; then
    log "prezto module already enabled: $module"
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] add '$module' to prezto pmodule in $file"
    return
  fi

  local tmp
  tmp="$(mktemp)"
  awk -v mod="$module" '
    BEGIN {in_pmodule=0; inserted=0}
    /^zstyle '\''\:prezto\:load'\'' pmodule/ {in_pmodule=1; print; next}
    {
      if (in_pmodule && !inserted && $0 ~ /'\''prompt'\''/) {
        printf "  '\''%s'\'' \\\n", mod
        inserted=1
      }
      print
      if (in_pmodule && $0 !~ /\\[[:space:]]*$/) {
        in_pmodule=0
      }
    }
    END {
      if (!inserted) {
        # Fallback: add minimal pmodule override containing git + autosuggestions.
        print ""
        print "zstyle '\''\:prezto\:load'\'' pmodule '\''environment'\'' '\''terminal'\'' '\''editor'\'' '\''history'\'' '\''directory'\'' '\''spectrum'\'' '\''utility'\'' '\''completion'\'' '\''history-substring-search'\'' '\''git'\'' '\''autosuggestions'\'' '\''prompt'\''"
      }
    }
  ' "$file" >"$tmp"
  mv "$tmp" "$file"
}

main() {
  if [[ "$ONLY_ZSH" -eq 1 ]]; then
    install_zsh_addons
    configure_prezto
    ensure_prezto_module git
    ensure_prezto_module autosuggestions
    set_prezto_theme_ansible_style
    set_default_shell_to_zsh
    log "zsh-only setup complete"
    return
  fi

  ensure_dir "$HOME_DIR/tmp"
  ensure_dir "$HOME_DIR/bin"

  install_os_packages
  install_python_packages
  install_zsh_addons
  configure_prezto
  ensure_prezto_module git
  ensure_prezto_module autosuggestions
  set_prezto_theme_ansible_style
  install_bashmarks
  set_default_shell_to_zsh

  log "optional tooling setup complete"
}

main "$@"

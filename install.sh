#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:?HOME is required}"
DRY_RUN=0

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

log() {
  printf '[dotfiles] %s\n' "$*"
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

ensure_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || run_cmd mkdir -p "$dir"
}

ensure_file() {
  local file="$1"
  ensure_dir "$(dirname "$file")"
  [[ -f "$file" ]] || run_cmd touch "$file"
}

run_as_root() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    run_cmd "$@"
  elif command -v sudo >/dev/null 2>&1; then
    run_cmd sudo "$@"
  else
    log "need root privileges to run: $*"
    return 1
  fi
}

replace_or_append() {
  local file="$1"
  local grep_regex="$2"
  local sed_expr="$3"
  local line="$4"

  ensure_file "$file"

  if grep -Eq "$grep_regex" "$file"; then
    run_cmd sed -E -i "$sed_expr" "$file"
  elif [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] append line to %s: %s\n' "$file" "$line"
  else
    printf '%s\n' "$line" >>"$file"
  fi
}

replace_or_prepend() {
  local file="$1"
  local grep_regex="$2"
  local sed_expr="$3"
  local line="$4"

  ensure_file "$file"

  if grep -Eq "$grep_regex" "$file"; then
    run_cmd sed -E -i "$sed_expr" "$file"
  elif [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] prepend line to %s: %s\n' "$file" "$line"
  else
    local tmp
    tmp="$(mktemp)"
    {
      printf '%s\n' "$line"
      cat "$file"
    } >"$tmp"
    mv "$tmp" "$file"
  fi
}

ensure_symlink() {
  local src="$1"
  local dest="$2"

  ensure_dir "$(dirname "$dest")"

  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    log "link ok: $dest -> $src"
    return
  fi

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
    log "backing up $dest to $backup"
    run_cmd mv "$dest" "$backup"
  elif [[ -L "$dest" ]]; then
    run_cmd rm -f "$dest"
  fi

  run_cmd ln -s "$src" "$dest"
  log "linked: $dest -> $src"
}

setup_emacs() {
  local file="$HOME_DIR/.emacs.d/init.el"
  local line="(load-file (expand-file-name \"$REPO_DIR/emacs.init.el\")); Customized config"
  replace_or_prepend \
    "$file" \
    '^\(load-file \(expand-file-name ".*"\)\); Customized config$' \
    "s|^\\(load-file \\(expand-file-name \".*\"\\)\\); Customized config$|$line|" \
    "$line"
}

setup_bashmarks() {
  local file="$HOME_DIR/.sdirs"
  local line="source $REPO_DIR/bashmarks.sdirs"
  replace_or_append \
    "$file" \
    '^source .*bashmarks\.sdirs$' \
    "s|^source .*bashmarks\\.sdirs$|$line|" \
    "$line"
}

setup_zsh() {
  local file="$HOME_DIR/.zshrc"
  local line="source $REPO_DIR/zshrc.custom.zsh"
  replace_or_append \
    "$file" \
    '^source .*(zsh\.zshrc|zshrc\.custom\.zsh)$' \
    "s|^source .*(zsh\\.zshrc\\|zshrc\\.custom\\.zsh)$|$line|" \
    "$line"
}

setup_prezto_theme() {
  local file="$HOME_DIR/.zpreztorc"
  local line="zstyle ':prezto:module:prompt' theme 'skwp'"
  if [[ -f "$file" ]]; then
    replace_or_append "$file" '^zstyle.*theme.*$' "s|^zstyle.*theme.*$|$line|" "$line"
  else
    log "skipping prezto theme; $file does not exist"
  fi
}

link_skills_to() {
  local dest_root="$1"
  local src_dir="$REPO_DIR/ai/skills"

  if [[ ! -d "$src_dir" ]]; then
    log "skipping $dest_root; $src_dir does not exist"
    return
  fi

  shopt -s nullglob
  local md
  for md in "$src_dir"/*.md; do
    local name
    name="$(basename "$md" .md)"
    ensure_dir "$dest_root/$name"
    ensure_symlink "$md" "$dest_root/$name/SKILL.md"
  done
  shopt -u nullglob
}

setup_ai_skills() {
  link_skills_to "$HOME_DIR/.claude/skills"
  link_skills_to "$HOME_DIR/.codex/skills"
}

setup_gemini_settings() {
  local src="$REPO_DIR/ai/gemini-settings.json"
  if [[ ! -f "$src" ]]; then
    log "skipping gemini settings; $src does not exist"
    return
  fi
  ensure_symlink "$src" "$HOME_DIR/.gemini/settings.json"
}

ensure_zsh_installed() {
  if command -v zsh >/dev/null 2>&1; then
    log "zsh already installed"
    return
  fi

  log "zsh not found; attempting installation"

  if command -v apt-get >/dev/null 2>&1; then
    run_as_root apt-get update
    run_as_root apt-get install -y zsh
  elif command -v dnf >/dev/null 2>&1; then
    run_as_root dnf install -y zsh
  elif command -v yum >/dev/null 2>&1; then
    run_as_root yum install -y zsh
  elif command -v pacman >/dev/null 2>&1; then
    run_as_root pacman -Sy --noconfirm zsh
  elif command -v apk >/dev/null 2>&1; then
    run_as_root apk add --no-cache zsh
  elif command -v brew >/dev/null 2>&1; then
    run_cmd brew install zsh
  else
    log "no supported package manager found; install zsh manually and rerun"
    return 1
  fi

  if [[ "$DRY_RUN" -eq 0 ]] && ! command -v zsh >/dev/null 2>&1; then
    log "zsh installation did not succeed"
    return 1
  fi
}

main() {
  ensure_zsh_installed
  setup_emacs
  setup_bashmarks
  setup_zsh
  setup_prezto_theme
  ensure_symlink "$REPO_DIR/tmux.conf" "$HOME_DIR/.tmux.conf"
  ensure_symlink "$REPO_DIR/ack.ackrc" "$HOME_DIR/.ackrc"
  setup_ai_skills
  setup_gemini_settings
  log "provisioning complete"
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/sharjeel/dotfiles.git}"
TARGET_DIR="${TARGET_DIR:-$HOME/.personalconfig}"

if [[ ! -d "$TARGET_DIR/.git" ]]; then
  echo "[dotfiles] cloning $REPO_URL into $TARGET_DIR"
  git clone "$REPO_URL" "$TARGET_DIR"
else
  echo "[dotfiles] using existing repo at $TARGET_DIR"
fi

exec bash "$TARGET_DIR/install.sh" "$@"
